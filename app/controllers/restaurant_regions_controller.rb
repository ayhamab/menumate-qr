class RestaurantRegionsController < ApplicationController
  before_action :set_restaurant
  before_action :require_team_access
  before_action :set_restaurant_region, only: [:destroy]

  def index
    @restaurant_regions = @restaurant.restaurant_regions.active.includes(:region)
    @available_regions = Region.active.countries.ordered
    @compliance_status = {}
    
    @restaurant_regions.each do |restaurant_region|
      @compliance_status[restaurant_region.region_id] = restaurant_region.compliance_status
    end
  end

  def create
    region = Region.find(params[:region_id])
    
    @restaurant_region = @restaurant.restaurant_regions.build(
      region: region,
      active: true,
      registered_date: Date.current
    )
    
    if @restaurant_region.save
      # Auto-check compliance for all menu items in this region
      checker = ComplianceChecker.new(restaurant: @restaurant, region: region)
      @restaurant.menu_items.each do |item|
        checker.check_menu_item(item, region)
      end
      
      redirect_to restaurant_restaurant_regions_path(@restaurant), 
                  notice: "Restaurant registered in #{region.name}. Compliance check initiated."
    else
      redirect_to restaurant_restaurant_regions_path(@restaurant), 
                  alert: "Error registering region: #{@restaurant_region.errors.full_messages.join(', ')}"
    end
  end

  def destroy
    region_name = @restaurant_region.region.name
    @restaurant_region.update(active: false)
    redirect_to restaurant_restaurant_regions_path(@restaurant), 
                notice: "Removed from #{region_name}."
  end

  private

  def set_restaurant
    @restaurant = Restaurant.find(params[:restaurant_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to restaurants_path, alert: "Restaurant not found."
  end

  def set_restaurant_region
    @restaurant_region = @restaurant.restaurant_regions.find(params[:id])
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

