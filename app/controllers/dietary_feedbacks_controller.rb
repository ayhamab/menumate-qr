class DietaryFeedbacksController < ApplicationController
  before_action :set_restaurant
  before_action :set_menu_item, only: [:new, :create]
  before_action :set_feedback, only: [:show, :resolve]
  before_action :require_team_access, only: [:index, :show, :resolve, :statistics]

  def index
    @feedbacks = @restaurant.dietary_feedbacks.includes(:menu_item, :user).recent
    @feedbacks = @feedbacks.where(feedback_type: params[:type]) if params[:type].present?
    @feedbacks = @feedbacks.where(severity: params[:severity]) if params[:severity].present?
    @feedbacks = @feedbacks.unresolved if params[:unresolved] == 'true'
    @feedbacks = @feedbacks.where(menu_item_id: params[:menu_item_id]) if params[:menu_item_id].present?
    
    @stats = {
      total: @feedbacks.count,
      unresolved: @restaurant.dietary_feedbacks.unresolved.count,
      by_type: @restaurant.dietary_feedbacks.group(:feedback_type).count,
      by_severity: @restaurant.dietary_feedbacks.group(:severity).count,
      critical: @restaurant.dietary_feedbacks.where(severity: 'critical', resolved: false).count
    }
  end

  def show
  end

  def new
    @feedback = @restaurant.dietary_feedbacks.build(
      menu_item: @menu_item,
      feedback_type: params[:type] || 'other',
      severity: 'medium',
      user: current_user
    )
  end

  def create
    @feedback = @restaurant.dietary_feedbacks.build(feedback_params)
    @feedback.menu_item = @menu_item
    @feedback.user = current_user if respond_to?(:current_user) && current_user
    
    if @feedback.save
      # Auto-determine severity based on feedback type
      if @feedback.feedback_type == 'allergen_issue'
        @feedback.update(severity: 'critical')
      elsif @feedback.feedback_type == 'incorrect_tag'
        @feedback.update(severity: 'high')
      end
      
      redirect_to menu_restaurant_path(@restaurant), 
                  notice: "Thank you for your feedback! We'll review it and make improvements."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def resolve
    if @feedback.update(
      resolved: true,
      resolved_at: Time.current,
      resolved_by: current_user,
      resolution_notes: params[:resolution_notes]
    )
      # Optionally update menu item based on feedback
      if params[:apply_suggestions] == 'true' && @feedback.suggested_tags.present?
        @feedback.menu_item.update(
          dietary_tags: (@feedback.menu_item.dietary_tags || []) | @feedback.suggested_tags
        )
      end
      
      redirect_to restaurant_dietary_feedbacks_path(@restaurant), 
                  notice: "Feedback marked as resolved."
    else
      redirect_to restaurant_dietary_feedback_path(@restaurant, @feedback), 
                  alert: "Failed to resolve feedback."
    end
  end

  def statistics
    @feedbacks = @restaurant.dietary_feedbacks
    
    @stats = {
      total: @feedbacks.count,
      resolved: @feedbacks.resolved.count,
      unresolved: @feedbacks.unresolved.count,
      by_type: @feedbacks.group(:feedback_type).count,
      by_severity: @feedbacks.group(:severity).count,
      by_menu_item: @feedbacks.group(:menu_item_id).count,
      recent_trends: @feedbacks.group_by { |f| f.created_at.to_date }.transform_values(&:count)
    }
    
    @top_issues = @feedbacks.group(:menu_item_id)
                            .count
                            .sort_by { |_, count| -count }
                            .first(10)
                            .map { |item_id, count| 
                              { menu_item: MenuItem.find(item_id), count: count } 
                            }
  end

  private

  def set_restaurant
    @restaurant = Restaurant.find(params[:restaurant_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to restaurants_path, alert: "Restaurant not found."
  end

  def set_menu_item
    @menu_item = @restaurant.menu_items.find(params[:menu_item_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to @restaurant, alert: "Menu item not found."
  end

  def set_feedback
    @feedback = @restaurant.dietary_feedbacks.find(params[:id])
  end

  def require_team_access
    return true if action_name == 'new' || action_name == 'create' # Public access for feedback
    
    unless can_access_restaurant?(@restaurant)
      redirect_to @restaurant, alert: "You don't have access to this restaurant."
    end
  end

  def can_access_restaurant?(restaurant)
    return false unless respond_to?(:current_user) && current_user
    return true if restaurant.user == current_user
    restaurant.restaurant_teams.active.exists?(user: current_user)
  end

  def feedback_params
    params.require(:dietary_feedback).permit(
      :feedback_type, :severity, :message, :contact_email, :contact_phone,
      reported_tags: [], suggested_tags: []
    )
  end
end

