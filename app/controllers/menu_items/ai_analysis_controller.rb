class MenuItems::AiAnalysisController < ApplicationController
  before_action :authenticate_user!
  before_action :set_restaurant
  before_action :set_menu_item
  before_action :authorize_owner

  # POST /restaurants/:restaurant_id/menu_items/:id/ai_analysis/analyze
  def analyze
    analyzer = MenuItemAiAnalyzer.new(@menu_item)
    result = analyzer.analyze

    respond_to do |format|
      format.json do
        if result[:success]
          render json: {
            success: true,
            suggestions: result[:suggestions]
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
          @suggestions = result[:suggestions]
          render :suggest_improvements
        else
          redirect_to restaurant_menu_item_path(@restaurant, @menu_item),
                      alert: "AI analysis failed: #{result[:error]}"
        end
      end
    end
  end

  # PATCH /restaurants/:restaurant_id/menu_items/:id/ai_analysis/apply
  def apply_suggestions
    suggestions = params[:suggestions] || {}
    
    updates = {}
    updates[:dietary_tags] = suggestions[:dietary_tags] if suggestions[:dietary_tags].present?
    updates[:allergens] = suggestions[:allergens] if suggestions[:allergens].present?
    updates[:description] = suggestions[:description] if suggestions[:description].present?

    if @menu_item.update(updates)
      redirect_to restaurant_menu_item_path(@restaurant, @menu_item),
                  notice: "Menu item updated with AI suggestions successfully."
    else
      redirect_to restaurant_menu_item_path(@restaurant, @menu_item),
                  alert: "Failed to update menu item: #{@menu_item.errors.full_messages.join(', ')}"
    end
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
end
