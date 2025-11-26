class MenuItemCompliancesController < ApplicationController
  before_action :set_restaurant
  before_action :set_menu_item
  before_action :require_team_access
  before_action :set_compliance, only: [:show, :update]

  def index
    @menu_item_compliances = @restaurant.menu_items
                                        .joins(:menu_item_compliances)
                                        .includes(:menu_item_compliances)
                                        .distinct
    
    @regions = @restaurant.regions.active
    @dietary_laws = DietaryLaw.active.ordered
    
    # Filter by region if specified
    if params[:region_id].present?
      @region = @regions.find(params[:region_id])
      @menu_item_compliances = @menu_item_compliances
                              .where(menu_item_compliances: { region_id: @region.id })
    end
    
    # Filter by status
    if params[:status].present?
      @menu_item_compliances = @menu_item_compliances
                              .where(menu_item_compliances: { status: params[:status] })
    end
  end

  def show
    @violations = @compliance.violations || []
  end

  def update
    if @compliance.update(compliance_params)
      redirect_to restaurant_menu_item_compliance_path(@restaurant, @menu_item, @compliance), 
                  notice: "Compliance status updated."
    else
      render :show, status: :unprocessable_entity
    end
  end

  def check_all
    region = Region.find(params[:region_id]) if params[:region_id].present?
    
    if region
      checker = ComplianceChecker.new(restaurant: @restaurant, region: region)
      @restaurant.menu_items.each do |item|
        checker.check_menu_item(item, region)
      end
      redirect_to restaurant_menu_item_compliances_path(@restaurant, region_id: region.id), 
                  notice: "Compliance check completed for all menu items in #{region.name}."
    else
      # Check all regions
      @restaurant.restaurant_regions.active.each do |restaurant_region|
        checker = ComplianceChecker.new(restaurant: @restaurant, region: restaurant_region.region)
        @restaurant.menu_items.each do |item|
          checker.check_menu_item(item, restaurant_region.region)
        end
      end
      redirect_to restaurant_menu_item_compliances_path(@restaurant), 
                  notice: "Compliance check completed for all regions."
    end
  end

  private

  def set_restaurant
    @restaurant = Restaurant.find(params[:restaurant_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to restaurants_path, alert: "Restaurant not found."
  end

  def set_menu_item
    @menu_item = @restaurant.menu_items.find(params[:menu_item_id]) if params[:menu_item_id].present?
  end

  def set_compliance
    @compliance = @menu_item.menu_item_compliances.find(params[:id])
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

  def compliance_params
    params.require(:menu_item_compliance).permit(:status, :certified, :certification_number, notes: [])
  end
end

