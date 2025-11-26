class CorporateAccounts::MenuItemsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_corporate_account
  before_action :authorize_access
  before_action :set_menu_item, only: [:show, :edit, :update, :destroy]

  # GET /corporate_accounts/:corporate_account_id/menu_items
  def index
    @menu_items = MenuItem.joins(:restaurant)
                          .where(restaurants: { corporate_account_id: @corporate_account.id })
                          .includes(:restaurant, :location)
                          .ordered
    
    # Filters
    @menu_items = @menu_items.where(restaurant_id: params[:restaurant_id]) if params[:restaurant_id].present?
    @menu_items = @menu_items.where(location_id: params[:location_id]) if params[:location_id].present?
    @menu_items = @menu_items.by_category(params[:category]) if params[:category].present?
    
    @restaurants = @corporate_account.restaurants.order(:name)
    @locations = Location.joins(:restaurant)
                         .where(restaurants: { corporate_account_id: @corporate_account.id })
                         .order(:name)
  end

  # GET /corporate_accounts/:corporate_account_id/menu_items/:id
  def show
  end

  # GET /corporate_accounts/:corporate_account_id/menu_items/new
  def new
    @menu_item = MenuItem.new
    @restaurants = @corporate_account.restaurants.order(:name)
  end

  # POST /corporate_accounts/:corporate_account_id/menu_items
  def create
    @menu_item = MenuItem.new(menu_item_params)
    @restaurant = @corporate_account.restaurants.find(menu_item_params[:restaurant_id])
    @menu_item.restaurant = @restaurant
    
    if @menu_item.save
      redirect_to corporate_account_menu_item_path(@corporate_account, @menu_item), 
                  notice: "Menu item created successfully."
    else
      @restaurants = @corporate_account.restaurants.order(:name)
      render :new, status: :unprocessable_entity
    end
  end

  # GET /corporate_accounts/:corporate_account_id/menu_items/:id/edit
  def edit
    @restaurants = @corporate_account.restaurants.order(:name)
  end

  # PATCH/PUT /corporate_accounts/:corporate_account_id/menu_items/:id
  def update
    if @menu_item.update(menu_item_params)
      redirect_to corporate_account_menu_item_path(@corporate_account, @menu_item), 
                  notice: "Menu item updated successfully."
    else
      @restaurants = @corporate_account.restaurants.order(:name)
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /corporate_accounts/:corporate_account_id/menu_items/:id
  def destroy
    @menu_item.destroy
    redirect_to corporate_account_menu_items_path(@corporate_account), 
                notice: "Menu item deleted successfully."
  end

  # GET /corporate_accounts/:corporate_account_id/menu_items/bulk_edit
  def bulk_edit
    @menu_items = MenuItem.joins(:restaurant)
                          .where(restaurants: { corporate_account_id: @corporate_account.id })
                          .where(id: params[:menu_item_ids])
                          .includes(:restaurant, :location)
    @restaurants = @corporate_account.restaurants.order(:name)
  end

  # PATCH /corporate_accounts/:corporate_account_id/menu_items/bulk_update
  def bulk_update
    menu_item_ids = params[:menu_item_ids] || []
    updates = params[:updates] || {}
    
    menu_items = MenuItem.joins(:restaurant)
                        .where(restaurants: { corporate_account_id: @corporate_account.id })
                        .where(id: menu_item_ids)
    
    updated_count = 0
    menu_items.each do |menu_item|
      if menu_item.update(updates.permit(:price, :category, :active))
        updated_count += 1
      end
    end
    
    redirect_to corporate_account_menu_items_path(@corporate_account), 
                notice: "Updated #{updated_count} menu items successfully."
  end

  private

  def set_corporate_account
    @corporate_account = CorporateAccount.find(params[:corporate_account_id])
  end

  def set_menu_item
    @menu_item = MenuItem.joins(:restaurant)
                        .where(restaurants: { corporate_account_id: @corporate_account.id })
                        .find(params[:id])
  end

  def authorize_access
    unless @corporate_account.has_user?(current_user)
      redirect_to corporate_accounts_path, alert: "You don't have access to this corporate account."
    end
  end

  def menu_item_params
    params.require(:menu_item).permit(:name, :description, :price, :category, :position, :active, 
                                      :restaurant_id, :location_id, :image, 
                                      dietary_tags: [], allergens: [],
                                      name_translations: {}, description_translations: {})
  end
end
