class FoodWasteAnalyticsController < ApplicationController
  before_action :set_restaurant
  before_action :require_team_access
  before_action :require_analytics_permission

  # GET /restaurants/:restaurant_id/food_waste_analytics
  def index
    @period_days = params[:period_days].present? ? params[:period_days].to_i : 30
    @analysis = FoodWasteAnalysis.new(@restaurant, period_days: @period_days)
    
    @summary = @analysis.summary
    @waste_risk_items = @analysis.waste_risk_items
    @unpopular_items = @analysis.unpopular_items(threshold: 5)
    @items_with_no_activity = @analysis.items_with_no_activity
    @declining_items = @analysis.declining_items
  end

  # GET /restaurants/:restaurant_id/food_waste_analytics/:menu_item_id
  def show
    @menu_item = @restaurant.menu_items.find(params[:menu_item_id])
    @period_days = params[:period_days].present? ? params[:period_days].to_i : 30
    
    start_date = Date.current - @period_days.days
    end_date = Date.current
    
    # Get item statistics directly
    analytics = MenuItemAnalytics.where(menu_item: @menu_item)
                                 .by_date_range(start_date, end_date)
    
    last_analytics = analytics.order(date: :desc).first
    
    @item_stats = {
      total_views: analytics.sum(:views) || 0,
      total_clicks: analytics.sum(:clicks) || 0,
      total_orders: analytics.sum(:orders) || 0,
      total_revenue: analytics.sum(:revenue) || 0,
      last_viewed: last_analytics&.date,
      days_since_view: last_analytics ? (Date.current - last_analytics.date).to_i : nil
    }
    
    # Get daily analytics
    @daily_analytics = analytics.order(date: :asc)
    
    # Calculate trends
    @trends = calculate_trends(@daily_analytics)
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

  def require_analytics_permission
    unless can_view_analytics?(@restaurant)
      redirect_to restaurant_path(@restaurant), alert: "You don't have permission to view analytics."
    end
  end

  def can_access_restaurant?(restaurant)
    return false unless respond_to?(:current_user) && current_user
    return true if restaurant.user == current_user
    restaurant.restaurant_teams.active.exists?(user: current_user)
  end

  def can_view_analytics?(restaurant)
    return false unless respond_to?(:current_user) && current_user
    return true if restaurant.user == current_user
    
    team_member = restaurant.restaurant_teams.active.find_by(user: current_user)
    team_member&.can_view_analytics? || false
  end

  def calculate_trends(daily_analytics)
    return {} if daily_analytics.empty?
    
    first_half = daily_analytics.first(daily_analytics.count / 2)
    second_half = daily_analytics.last(daily_analytics.count - first_half.count)
    
    {
      views_trend: calculate_trend(first_half.sum(&:views), second_half.sum(&:views)),
      clicks_trend: calculate_trend(first_half.sum(&:clicks), second_half.sum(&:clicks)),
      orders_trend: calculate_trend(first_half.sum(&:orders), second_half.sum(&:orders)),
      revenue_trend: calculate_trend(first_half.sum(&:revenue), second_half.sum(&:revenue))
    }
  end

  def calculate_trend(first_value, second_value)
    return 'stable' if first_value.zero? && second_value.zero?
    return 'increasing' if first_value.zero?
    
    change_percentage = ((second_value - first_value).to_f / first_value * 100).round(2)
    
    if change_percentage > 10
      'increasing'
    elsif change_percentage < -10
      'decreasing'
    else
      'stable'
    end
  end
end

