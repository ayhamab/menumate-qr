class MenuItems::NutritionController < ApplicationController
  before_action :authenticate_user!
  before_action :set_restaurant
  before_action :set_menu_item
  before_action :authorize_owner

  # POST /restaurants/:restaurant_id/menu_items/:id/nutrition/calculate
  def calculate
    service = NutritionApiService.new(@menu_item)
    result = service.fetch_nutrition_natural_language

    respond_to do |format|
      format.json do
        if result[:success]
          render json: {
            success: true,
            nutrition: result[:data],
            raw_data: result[:raw_data]
          }
        else
          render json: {
            success: false,
            error: result[:error]
          }, status: :unprocessable_entity
        end
      end
      format.html do
        if result[:success]
          @nutrition_data = result[:data]
          @raw_data = result[:raw_data]
          render 'menu_items/nutrition/show'
        else
          redirect_to restaurant_menu_item_path(@restaurant, @menu_item),
                      alert: "Failed to fetch nutrition data: #{result[:error]}"
        end
      end
    end
  end

  # PATCH /restaurants/:restaurant_id/menu_items/:id/nutrition/update
  def update
    nutrition_params = params.require(:nutrition).permit(
      :calories, :protein, :carbs, :fat, :fiber, :sugar, :sodium, :cholesterol
    )

    # Convert string values to appropriate types
    nutrition_data = {
      calories: nutrition_params[:calories]&.to_i,
      protein: nutrition_params[:protein]&.to_f,
      carbs: nutrition_params[:carbs]&.to_f,
      fat: nutrition_params[:fat]&.to_f,
      fiber: nutrition_params[:fiber]&.to_f,
      sugar: nutrition_params[:sugar]&.to_f,
      sodium: nutrition_params[:sodium]&.to_i,
      cholesterol: nutrition_params[:cholesterol]&.to_i,
      nutrition_api_provider: 'edamam',
      nutrition_last_updated: Time.current
    }

    if @menu_item.update(nutrition_data)
      redirect_to restaurant_menu_item_path(@restaurant, @menu_item),
                  notice: "Nutrition information updated successfully."
    else
      redirect_to restaurant_menu_item_path(@restaurant, @menu_item),
                  alert: "Failed to update nutrition information: #{@menu_item.errors.full_messages.join(', ')}"
    end
  end

  private

  def set_restaurant
    @restaurant = Restaurant.find(params[:restaurant_id])
  end

  def set_menu_item
    @menu_item = @restaurant.menu_items.find(params[:id])
  end

  def authorize_owner
    unless @restaurant.user == current_user || (@restaurant.corporate_account&.has_user?(current_user) && @restaurant.corporate_account.can_manage?(current_user))
      redirect_to restaurants_path, alert: "You don't have permission to manage this restaurant."
    end
  end
end
