class RecipesController < ApplicationController
  before_action :set_restaurant
  before_action :require_team_access
  before_action :require_edit_permission, except: [:index, :show]
  before_action :set_recipe, only: [:show, :edit, :update, :destroy, :scale]

  # GET /restaurants/:restaurant_id/recipes
  def index
    @recipes = @restaurant.recipes.includes(:menu_item, :ingredients).order(created_at: :desc)
    @recipes = @recipes.where(menu_item_id: params[:menu_item_id]) if params[:menu_item_id].present?
    @recipes = @recipes.where("name LIKE ?", "%#{params[:search]}%") if params[:search].present?
  end

  # GET /restaurants/:restaurant_id/recipes/:id
  def show
    @recipe_ingredients = @recipe.recipe_ingredients.includes(:ingredient).ordered
    @scaled_servings = params[:servings].present? ? params[:servings].to_i : @recipe.base_servings
    @scaled_ingredients = @recipe.ingredients_for_servings(@scaled_servings)
  end

  # GET /restaurants/:restaurant_id/recipes/new
  def new
    @recipe = @restaurant.recipes.build(base_servings: 1)
    @menu_items = @restaurant.menu_items.order(:name)
    @ingredients = Ingredient.order(:name)
  end

  # POST /restaurants/:restaurant_id/recipes
  def create
    @recipe = @restaurant.recipes.build(recipe_params)
    @menu_items = @restaurant.menu_items.order(:name)
    @ingredients = Ingredient.order(:name)

    if @recipe.save
      redirect_to restaurant_recipe_path(@restaurant, @recipe), notice: "Recipe created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # GET /restaurants/:restaurant_id/recipes/:id/edit
  def edit
    @menu_items = @restaurant.menu_items.order(:name)
    @ingredients = Ingredient.order(:name)
    @recipe_ingredients = @recipe.recipe_ingredients.includes(:ingredient).ordered
  end

  # PATCH/PUT /restaurants/:restaurant_id/recipes/:id
  def update
    @menu_items = @restaurant.menu_items.order(:name)
    @ingredients = Ingredient.order(:name)
    
    if @recipe.update(recipe_params)
      redirect_to restaurant_recipe_path(@restaurant, @recipe), notice: "Recipe updated successfully."
    else
      @recipe_ingredients = @recipe.recipe_ingredients.includes(:ingredient).ordered
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /restaurants/:restaurant_id/recipes/:id
  def destroy
    if @recipe.destroy
      redirect_to restaurant_recipes_path(@restaurant), notice: "Recipe deleted."
    else
      redirect_to restaurant_recipe_path(@restaurant, @recipe), alert: "Could not delete recipe."
    end
  end

  # GET /restaurants/:restaurant_id/recipes/:id/scale
  def scale
    servings = params[:servings].to_i
    if servings > 0
      @scaled_recipe = @recipe.scale_to_servings(servings)
      @scaled_ingredients = @recipe.ingredients_for_servings(servings)
      render json: {
        servings: servings,
        ingredients: @scaled_ingredients.map do |ri|
          {
            name: ri[:ingredient].name,
            quantity: ri[:quantity],
            unit: ri[:unit],
            preparation_method: ri[:preparation_method]
          }
        end
      }
    else
      render json: { error: "Invalid serving size" }, status: :bad_request
    end
  end

  private

  def set_restaurant
    @restaurant = Restaurant.find(params[:restaurant_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to restaurants_path, alert: "Restaurant not found."
  end

  def set_recipe
    @recipe = @restaurant.recipes.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to restaurant_recipes_path(@restaurant), alert: "Recipe not found."
  end

  def require_team_access
    unless can_access_restaurant?(@restaurant)
      redirect_to @restaurant, alert: "You don't have access to this restaurant."
    end
  end

  def require_edit_permission
    unless can_edit_menu_items?(@restaurant) || restaurant_owner?(@restaurant)
      redirect_to restaurant_recipes_path(@restaurant), alert: "You don't have permission to manage recipes."
    end
  end

  def can_access_restaurant?(restaurant)
    return false unless respond_to?(:current_user) && current_user
    return true if restaurant.user == current_user
    restaurant.restaurant_teams.active.exists?(user: current_user)
  end

  def recipe_params
    params.require(:recipe).permit(:name, :description, :instructions, :base_servings, :prep_time, :cook_time, :difficulty, :notes, :menu_item_id)
  end
end

