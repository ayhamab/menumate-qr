class Consultants::RestaurantsController < ApplicationController
  before_action :authenticate_consultant! if respond_to?(:authenticate_consultant!)
  before_action :set_consultant
  before_action :set_client
  before_action :set_restaurant
  before_action :check_access

  def show
    @menu_items = @restaurant.menu_items.includes(:location, :categories).ordered
    @menu_items_by_category = @menu_items.group_by(&:category)
    @recent_notes = @consultant.consultant_notes.by_restaurant(@restaurant).recent.limit(5)
    @active_tasks = @consultant.consultant_tasks.by_restaurant(@restaurant)
                               .where.not(status: ['completed', 'cancelled'])
                               .recent
    @recent_reports = @consultant.consultant_reports.by_restaurant(@restaurant).recent.limit(5)
  end

  def analytics
    return redirect_to consultants_client_restaurant_path(@client, @restaurant), 
                       alert: "You don't have permission to view analytics." unless @client.can_view_analytics?
    
    # Analytics data for consultant
    @menu_items = @restaurant.menu_items.includes(:menu_item_analytics)
    @total_views = @restaurant.menu_items.sum { |item| item.menu_item_analytics.sum(:views) }
    @total_clicks = @restaurant.menu_items.sum { |item| item.menu_item_analytics.sum(:clicks) }
    @total_orders = @restaurant.menu_items.sum { |item| item.menu_item_analytics.sum(:orders) }
  end

  def menu_analysis
    return redirect_to consultants_client_restaurant_path(@client, @restaurant), 
                       alert: "You don't have permission to view menu analysis." unless @client.can_view?
    
    @menu_items = @restaurant.menu_items.includes(:categories, :dietary_tags).ordered
    @menu_items_by_category = @menu_items.group_by(&:category)
    
    # Analysis data
    @total_items = @menu_items.count
    @items_with_images = @menu_items.select { |item| item.image.attached? }.count
    @items_with_dietary_tags = @menu_items.select { |item| item.dietary_tags.present? && item.dietary_tags.any? }.count
    @items_with_allergens = @menu_items.select { |item| item.has_allergens? }.count
    @average_price = @menu_items.average(:price)&.round(2) || 0
  end

  private

  def set_consultant
    @consultant = respond_to?(:current_consultant) ? current_consultant : nil
    return redirect_to new_consultant_session_path, alert: "Please sign in." unless @consultant
  end

  def set_client
    @client = @consultant.consultant_clients.find(params[:client_id])
  end

  def set_restaurant
    @restaurant = @client.restaurant
  end

  def check_access
    unless @client.can_view?
      redirect_to consultants_clients_path, alert: "You don't have access to this restaurant."
    end
  end
end

