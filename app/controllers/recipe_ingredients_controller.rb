class RecipeIngredientsController < ApplicationController
  before_action :set_restaurant
  before_action :set_recipe
  before_action :require_team_access
  before_action :require_edit_permission
  before_action :set_recipe_ingredient, only: [:update, :destroy]

  # POST /restaurants/:restaurant_id/recipes/:recipe_id/recipe_ingredients
  def create
    @recipe_ingredient = @recipe.recipe_ingredients.build(recipe_ingredient_params)
    
    # Set position if not provided
    if @recipe_ingredient.position.nil? || @recipe_ingredient.position.zero?
      max_position = @recipe.recipe_ingredients.maximum(:position) || 0
      @recipe_ingredient.position = max_position + 1
    end

    if @recipe_ingredient.save
      redirect_to restaurant_recipe_path(@restaurant, @recipe), notice: "Ingredient added to recipe."
    else
      @menu_items = @restaurant.menu_items.order(:name)
      @ingredients = Ingredient.order(:name)
      @recipe_ingredients = @recipe.recipe_ingredients.includes(:ingredient).ordered
      render 'recipes/edit', status: :unprocessable_entity
    end
  end

  # PATCH/PUT /restaurants/:restaurant_id/recipes/:recipe_id/recipe_ingredients/:id
  def update
    if @recipe_ingredient.update(recipe_ingredient_params)
      redirect_to restaurant_recipe_path(@restaurant, @recipe), notice: "Ingredient updated."
    else
      redirect_to restaurant_recipe_path(@restaurant, @recipe), alert: "Could not update ingredient."
    end
  end

  # DELETE /restaurants/:restaurant_id/recipes/:recipe_id/recipe_ingredients/:id
  def destroy
    if @recipe_ingredient.destroy
      redirect_to restaurant_recipe_path(@restaurant, @recipe), notice: "Ingredient removed from recipe."
    else
      redirect_to restaurant_recipe_path(@restaurant, @recipe), alert: "Could not remove ingredient."
    end
  end

  private

  def set_restaurant
    @restaurant = Restaurant.find(params[:restaurant_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to restaurants_path, alert: "Restaurant not found."
  end

  def set_recipe
    @recipe = @restaurant.recipes.find(params[:recipe_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to restaurant_recipes_path(@restaurant), alert: "Recipe not found."
  end

  def set_recipe_ingredient
    @recipe_ingredient = @recipe.recipe_ingredients.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to restaurant_recipe_path(@restaurant, @recipe), alert: "Recipe ingredient not found."
  end

  def require_team_access
    unless can_access_restaurant?(@restaurant)
      redirect_to @restaurant, alert: "You don't have access to this restaurant."
    end
  end

  def require_edit_permission
    unless can_edit_menu_items?(@restaurant) || restaurant_owner?(@restaurant)
      redirect_to restaurant_recipes_path(@restaurant), alert: "You don't have permission to manage recipe ingredients."
    end
  end

  def can_access_restaurant?(restaurant)
    return false unless respond_to?(:current_user) && current_user
    return true if restaurant.user == current_user
    restaurant.restaurant_teams.active.exists?(user: current_user)
  end

  def recipe_ingredient_params
    params.require(:recipe_ingredient).permit(:ingredient_id, :quantity, :unit, :preparation_method, :position, :notes)
  end
end

