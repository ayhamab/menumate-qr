class BrandsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_restaurant
  before_action :set_brand, only: [:show, :edit, :update, :destroy]
  before_action :authorize_owner

  # GET /restaurants/:restaurant_id/brands
  def index
    @brands = @restaurant.brands.ordered.includes(:menu_items, :qr_codes)
  end

  # GET /restaurants/:restaurant_id/brands/:id
  def show
    @menu_items = @brand.menu_items.ordered.includes(:ingredients, :promotions)
    @menu_items_by_category = @menu_items.group_by(&:category)
    @qr_codes = @brand.qr_codes.active.order(created_at: :desc)
  end

  # GET /restaurants/:restaurant_id/brands/new
  def new
    @brand = @restaurant.brands.build
  end

  # POST /restaurants/:restaurant_id/brands
  def create
    @brand = @restaurant.brands.build(brand_params)
    
    if @brand.save
      redirect_to restaurant_brand_path(@restaurant, @brand),
                  notice: "Brand created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # GET /restaurants/:restaurant_id/brands/:id/edit
  def edit
  end

  # PATCH/PUT /restaurants/:restaurant_id/brands/:id
  def update
    if @brand.update(brand_params)
      redirect_to restaurant_brand_path(@restaurant, @brand),
                  notice: "Brand updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /restaurants/:restaurant_id/brands/:id
  def destroy
    @brand.destroy
    redirect_to restaurant_brands_path(@restaurant),
                notice: "Brand deleted successfully."
  end

  private

  def set_restaurant
    @restaurant = Restaurant.find(params[:restaurant_id])
  end

  def set_brand
    @brand = @restaurant.brands.find(params[:id])
  end

  def authorize_owner
    unless @restaurant.user == current_user || (@restaurant.corporate_account&.has_user?(current_user) && @restaurant.corporate_account.can_manage?(current_user))
      redirect_to restaurants_path, alert: "You don't have permission to manage this restaurant."
    end
  end

  def brand_params
    params.require(:brand).permit(:name, :description, :logo_url, :brand_color, :active, :display_order)
  end
end
