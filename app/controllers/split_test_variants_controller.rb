class SplitTestVariantsController < ApplicationController
  before_action :set_restaurant
  before_action :set_split_test
  before_action :require_team_access
  before_action :require_edit_permission
  before_action :set_variant, only: [:show, :edit, :update, :destroy]

  # GET /restaurants/:restaurant_id/split_tests/:split_test_id/variants
  def index
    @variants = @split_test.split_test_variants.order(weight: :desc, created_at: :asc)
  end

  # GET /restaurants/:restaurant_id/split_tests/:split_test_id/variants/new
  def new
    @variant = @split_test.split_test_variants.build(weight: 50, is_control: @split_test.split_test_variants.empty?)
    
    # Pre-fill with menu item data if applicable
    if @split_test.menu_item.present?
      case @split_test.test_type
      when 'description'
        @variant.description = @split_test.menu_item.description
      when 'price'
        @variant.price = @split_test.menu_item.price
      when 'placement'
        @variant.position = @split_test.menu_item.position
      end
    end
  end

  # POST /restaurants/:restaurant_id/split_tests/:split_test_id/variants
  def create
    @variant = @split_test.split_test_variants.build(variant_params)

    if @variant.save
      redirect_to restaurant_split_test_path(@restaurant, @split_test), notice: "Variant created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # GET /restaurants/:restaurant_id/split_tests/:split_test_id/variants/:id/edit
  def edit
  end

  # PATCH/PUT /restaurants/:restaurant_id/split_tests/:split_test_id/variants/:id
  def update
    if @variant.update(variant_params)
      redirect_to restaurant_split_test_path(@restaurant, @split_test), notice: "Variant updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /restaurants/:restaurant_id/split_tests/:split_test_id/variants/:id
  def destroy
    if @variant.destroy
      redirect_to restaurant_split_test_path(@restaurant, @split_test), notice: "Variant deleted."
    else
      redirect_to restaurant_split_test_path(@restaurant, @split_test), alert: "Could not delete variant."
    end
  end

  private

  def set_restaurant
    @restaurant = Restaurant.find(params[:restaurant_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to restaurants_path, alert: "Restaurant not found."
  end

  def set_split_test
    @split_test = @restaurant.split_tests.find(params[:split_test_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to restaurant_split_tests_path(@restaurant), alert: "Split test not found."
  end

  def set_variant
    @variant = @split_test.split_test_variants.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to restaurant_split_test_path(@restaurant, @split_test), alert: "Variant not found."
  end

  def require_team_access
    unless can_access_restaurant?(@restaurant)
      redirect_to @restaurant, alert: "You don't have access to this restaurant."
    end
  end

  def require_edit_permission
    unless can_edit_menu_items?(@restaurant) || restaurant_owner?(@restaurant)
      redirect_to restaurant_split_tests_path(@restaurant), alert: "You don't have permission to manage variants."
    end
  end

  def can_access_restaurant?(restaurant)
    return false unless respond_to?(:current_user) && current_user
    return true if restaurant.user == current_user
    restaurant.restaurant_teams.active.exists?(user: current_user)
  end

  def variant_params
    params.require(:split_test_variant).permit(:name, :description, :position, :price, :weight, :is_control, :notes, :image)
  end
end

