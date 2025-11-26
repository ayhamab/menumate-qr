class DemographicDataController < ApplicationController
  before_action :set_restaurant
  before_action :require_team_access
  before_action :set_demographic_data, only: [:show, :edit, :update]

  def index
    @demographic_data = @restaurant.demographic_data.includes(:location).recent
    # @available_regions = Region.active.countries.ordered if defined?(Region)
  end

  def show
  end

  def new
    @demographic_data = @restaurant.demographic_data.build(
      data_source: 'manual_entry',
      region_code: extract_region_code(@restaurant)
    )
  end

  def create
    @demographic_data = @restaurant.demographic_data.build(demographic_data_params)
    
    if @demographic_data.save
      # Auto-generate predictions for all menu items
      redirect_to restaurant_demographic_data_path(@restaurant, @demographic_data), 
                  notice: "Demographic data added. Generating predictions..."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @demographic_data.update(demographic_data_params)
      redirect_to restaurant_demographic_data_path(@restaurant, @demographic_data), 
                  notice: "Demographic data updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def import
    # Placeholder for importing demographic data from external APIs
    # This would integrate with Census API, third-party services, etc.
    redirect_to restaurant_demographic_data_index_path(@restaurant), 
                notice: "Import feature coming soon."
  end

  private

  def set_restaurant
    @restaurant = Restaurant.find(params[:restaurant_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to restaurants_path, alert: "Restaurant not found."
  end

  def set_demographic_data
    @demographic_data = @restaurant.demographic_data.find(params[:id])
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

  def extract_region_code(restaurant)
    if restaurant.address.include?('USA') || restaurant.address.match(/\bUS\b/)
      'US'
    elsif restaurant.address.include?('UK')
      'GB'
    else
      'US'
    end
  end

  def demographic_data_params
    params.require(:demographic_data).permit(
      :location_id, :region_code, :data_source, :verified, :data_date, :notes,
      age_distribution: {}, income_distribution: {}, cultural_preferences: {},
      dietary_preferences: {}, dining_preferences: {}
    )
  end
end

