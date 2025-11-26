class MenuItemIngredientsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_restaurant
  before_action :set_menu_item
  before_action :authorize_owner

  # GET /restaurants/:restaurant_id/menu_items/:menu_item_id/ingredients
  def index
    @menu_item_ingredients = @menu_item.menu_item_ingredients.includes(:ingredient).order(:created_at)
    @ingredients = Ingredient.order(:name)
    @cross_contamination_warnings = @menu_item.cross_contamination_warnings(@restaurant.menu_items)
  end

  # POST /restaurants/:restaurant_id/menu_items/:menu_item_id/ingredients
  def create
    ingredient = Ingredient.find_or_create_by(name: params[:ingredient_name]) do |ing|
      ing.allergen_type = params[:allergen_type] if params[:allergen_type].present?
      ing.preparation_area = params[:preparation_area] if params[:preparation_area].present?
      ing.notes = params[:notes] if params[:notes].present?
    end

    menu_item_ingredient = @menu_item.menu_item_ingredients.build(
      ingredient: ingredient,
      quantity: params[:quantity],
      preparation_method: params[:preparation_method]
    )

    if menu_item_ingredient.save
      # Update allergens on menu item based on ingredients
      update_menu_item_allergens
      
      redirect_to restaurant_menu_item_ingredients_path(@restaurant, @menu_item),
                  notice: "Ingredient added successfully."
    else
      @menu_item_ingredients = @menu_item.menu_item_ingredients.includes(:ingredient).order(:created_at)
      @ingredients = Ingredient.order(:name)
      @cross_contamination_warnings = @menu_item.cross_contamination_warnings(@restaurant.menu_items)
      render :index, status: :unprocessable_entity
    end
  end

  # DELETE /restaurants/:restaurant_id/menu_items/:menu_item_id/ingredients/:id
  def destroy
    menu_item_ingredient = @menu_item.menu_item_ingredients.find(params[:id])
    menu_item_ingredient.destroy
    
    # Update allergens on menu item based on remaining ingredients
    update_menu_item_allergens
    
    redirect_to restaurant_menu_item_ingredients_path(@restaurant, @menu_item),
                notice: "Ingredient removed successfully."
  end

  private

  def set_restaurant
    @restaurant = Restaurant.find(params[:restaurant_id])
  end

  def set_menu_item
    @menu_item = @restaurant.menu_items.find(params[:menu_item_id])
  end

  def authorize_owner
    unless @restaurant.user == current_user || (@restaurant.corporate_account&.has_user?(current_user) && @restaurant.corporate_account.can_manage?(current_user))
      redirect_to restaurants_path, alert: "You don't have permission to manage this restaurant."
    end
  end

  def update_menu_item_allergens
    # Automatically update menu item allergens based on ingredients
    ingredient_allergens = @menu_item.ingredients.allergenic.pluck(:allergen_type).compact.uniq
    current_allergens = @menu_item.allergens || []
    
    # Merge ingredient allergens with manually set allergens
    updated_allergens = (current_allergens + ingredient_allergens).uniq
    @menu_item.update(allergens: updated_allergens) if updated_allergens != current_allergens
  end
end
