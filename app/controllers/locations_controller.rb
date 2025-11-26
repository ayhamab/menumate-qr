class LocationsController < ApplicationController
  before_action :set_restaurant
  before_action :require_team_access
  before_action :require_edit_permission, except: [:index, :show, :find_nearby]

  # GET /restaurants/:restaurant_id/locations
  def index
    @locations = @restaurant.locations.includes(:menu_items).order(:name)
  end

  # GET /restaurants/:restaurant_id/locations/:id
  def show
    @location = @restaurant.locations.find(params[:id])
    @menu_items = @location.menu_items.ordered
  end

  # GET /restaurants/:restaurant_id/locations/find_nearby
  def find_nearby
    latitude = params[:latitude].to_f
    longitude = params[:longitude].to_f
    
    if latitude.zero? || longitude.zero?
      render json: { error: "Invalid coordinates" }, status: :bad_request
      return
    end

    nearest = find_nearest_location(@restaurant, latitude, longitude, max_distance_km: 50)
    
    if nearest
      distance = distance_between(latitude, longitude, nearest.latitude, nearest.longitude)
      render json: {
        location: {
          id: nearest.id,
          name: nearest.name,
          address: nearest.address,
          distance: distance
        }
      }
    else
      render json: { location: nil, message: "No nearby location found" }
    end
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

  def require_edit_permission
    unless can_edit_menu_items?(@restaurant) || restaurant_owner?(@restaurant)
      redirect_to restaurant_locations_path(@restaurant), alert: "You don't have permission to manage locations."
    end
  end

  def can_access_restaurant?(restaurant)
    return false unless respond_to?(:current_user) && current_user
    return true if restaurant.user == current_user
    restaurant.restaurant_teams.active.exists?(user: current_user)
  end
end

