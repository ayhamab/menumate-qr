class CorporateAccountsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_corporate_account, only: [:show, :edit, :update, :dashboard]
  before_action :authorize_access, only: [:show, :edit, :update, :dashboard]
  before_action :authorize_admin, only: [:edit, :update]

  # GET /corporate_accounts
  def index
    @corporate_accounts = current_user.corporate_accounts.active
  end

  # GET /corporate_accounts/:id
  def show
    @restaurants = @corporate_account.restaurants.includes(:locations, :menu_items)
    @total_locations = @corporate_account.total_locations
    @total_menu_items = @corporate_account.total_menu_items
  end

  # GET /corporate_accounts/new
  def new
    @corporate_account = CorporateAccount.new
  end

  # POST /corporate_accounts
  def create
    @corporate_account = CorporateAccount.new(corporate_account_params)
    
    if @corporate_account.save
      # Add creator as admin
      @corporate_account.corporate_account_users.create!(
        user: current_user,
        role: 'admin',
        active: true
      )
      redirect_to @corporate_account, notice: "Corporate account created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # GET /corporate_accounts/:id/edit
  def edit
  end

  # PATCH/PUT /corporate_accounts/:id
  def update
    if @corporate_account.update(corporate_account_params)
      redirect_to @corporate_account, notice: "Corporate account updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # GET /corporate_accounts/:id/dashboard
  def dashboard
    @restaurants = @corporate_account.restaurants.includes(:locations, :menu_items)
    @locations = Location.joins(:restaurant).where(restaurants: { corporate_account_id: @corporate_account.id })
    @menu_items = MenuItem.joins(:restaurant).where(restaurants: { corporate_account_id: @corporate_account.id })
    
    # Statistics
    @stats = {
      total_restaurants: @restaurants.count,
      total_locations: @locations.count,
      total_menu_items: @menu_items.count,
      active_locations: @locations.active.count,
      restaurants_with_locations: @restaurants.select { |r| r.locations.any? }.count
    }
  end

  private

  def set_corporate_account
    @corporate_account = CorporateAccount.find(params[:id])
  end

  def authorize_access
    unless @corporate_account.has_user?(current_user)
      redirect_to corporate_accounts_path, alert: "You don't have access to this corporate account."
    end
  end

  def authorize_admin
    unless @corporate_account.can_manage?(current_user)
      redirect_to @corporate_account, alert: "Admin access required."
    end
  end

  def corporate_account_params
    params.require(:corporate_account).permit(:name, :email, :phone_number, :subscription_tier, :active, :max_restaurants, :max_locations_per_restaurant, :notes, :billing_address, :tax_id)
  end
end
