class ActivityLogsController < ApplicationController
  before_action :set_restaurant
  before_action :require_team_access

  # GET /restaurants/:restaurant_id/activity_logs
  def index
    @activity_logs = @restaurant.activity_logs
                                  .includes(:user, :trackable)
                                  .recent
                                  .limit(100)
    
    # Filter by activity type if provided
    @activity_logs = @activity_logs.by_type(params[:type]) if params[:type].present?
    
    # Filter by user if provided
    @activity_logs = @activity_logs.by_user(User.find(params[:user_id])) if params[:user_id].present?
  end

  private

  def set_restaurant
    @restaurant = Restaurant.find(params[:restaurant_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to restaurants_path, alert: "Restaurant not found."
  end

  def require_team_access
    unless can_access_restaurant?(@restaurant)
      redirect_to @restaurant, alert: "You don't have access to this restaurant."
    end
  end

  def can_access_restaurant?(restaurant)
    return false unless respond_to?(:current_user) && current_user
    return true if restaurant.user == current_user
    restaurant.restaurant_teams.active.exists?(user: current_user)
  end
end

