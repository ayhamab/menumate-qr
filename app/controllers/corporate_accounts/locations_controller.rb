class CorporateAccounts::LocationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_corporate_account
  before_action :authorize_access
  before_action :set_location, only: [:show, :edit, :update, :destroy]
  before_action :set_restaurant, only: [:new, :create]

  # GET /corporate_accounts/:corporate_account_id/locations
  def index
    @locations = Location.joins(:restaurant)
                        .where(restaurants: { corporate_account_id: @corporate_account.id })
                        .includes(:restaurant)
    @locations = @locations.where(restaurant_id: params[:restaurant_id]) if params[:restaurant_id].present?
  end

  # GET /corporate_accounts/:corporate_account_id/locations/:id
  def show
  end

  # GET /corporate_accounts/:corporate_account_id/locations/new
  def new
    @location = @restaurant.locations.build
  end

  # POST /corporate_accounts/:corporate_account_id/locations
  def create
    @location = @restaurant.locations.build(location_params)
    
    unless @corporate_account.can_add_location?(@restaurant)
      redirect_to corporate_account_locations_path(@corporate_account), 
                  alert: "Location limit reached for this restaurant."
      return
    end

    if @location.save
      redirect_to corporate_account_location_path(@corporate_account, @location), 
                  notice: "Location created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # GET /corporate_accounts/:corporate_account_id/locations/:id/edit
  def edit
  end

  # PATCH/PUT /corporate_accounts/:corporate_account_id/locations/:id
  def update
    if @location.update(location_params)
      redirect_to corporate_account_location_path(@corporate_account, @location), 
                  notice: "Location updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /corporate_accounts/:corporate_account_id/locations/:id
  def destroy
    @location.destroy
    redirect_to corporate_account_locations_path(@corporate_account), 
                notice: "Location deleted successfully."
  end

  private

  def set_corporate_account
    @corporate_account = CorporateAccount.find(params[:corporate_account_id])
  end

  def set_location
    @location = Location.joins(:restaurant)
                      .where(restaurants: { corporate_account_id: @corporate_account.id })
                      .find(params[:id])
  end

  def set_restaurant
    @restaurant = @corporate_account.restaurants.find(params[:restaurant_id] || location_params[:restaurant_id])
  end

  def authorize_access
    unless @corporate_account.has_user?(current_user)
      redirect_to corporate_accounts_path, alert: "You don't have access to this corporate account."
    end
  end

  def location_params
    params.require(:location).permit(:name, :address, :phone_number, :email, :manager_name, :active, :latitude, :longitude, :notes, :timezone, :restaurant_id)
  end
end
