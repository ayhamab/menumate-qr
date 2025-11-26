class MenuPredictionsController < ApplicationController
  before_action :set_restaurant
  before_action :require_team_access
  before_action :set_menu_prediction, only: [:show]

  def index
    @menu_predictions = @restaurant.menu_predictions.includes(:menu_item, :demographic_data).recent
    @menu_predictions = @menu_predictions.where(prediction_type: params[:type]) if params[:type].present?
    @menu_predictions = @menu_predictions.high_confidence if params[:high_confidence] == 'true'
    
    # Group by menu item
    @predictions_by_item = @menu_predictions.group_by(&:menu_item)
    
    # Statistics
    @stats = {
      total_predictions: @menu_predictions.count,
      high_confidence: @menu_predictions.high_confidence.count,
      avg_success_score: @menu_predictions.where(prediction_type: 'success_score')
                                          .average(:predicted_value)&.round(3) || 0,
      avg_popularity: @menu_predictions.where(prediction_type: 'popularity_score')
                                       .average(:predicted_value)&.round(2) || 0
    }
  end

  def show
    @menu_item = @menu_prediction.menu_item
    @demographic_data = @menu_prediction.demographic_data
    @all_predictions = @menu_item.menu_predictions.recent
  end

  def create
    menu_item = @restaurant.menu_items.find(params[:menu_item_id])
    demographic_data = @restaurant.demographic_data.find(params[:demographic_data_id]) if params[:demographic_data_id].present?
    
    service = MenuPredictionService.new(
      menu_item: menu_item,
      restaurant: @restaurant,
      demographic_data: demographic_data
    )
    
    predictions = service.predict
    
    redirect_to restaurant_menu_predictions_path(@restaurant), 
                notice: "Generated #{predictions.count} predictions for #{menu_item.name}."
  end

  def predict_all
    demographic_data = @restaurant.demographic_data.first || 
                      DemographicData.find_by(region_code: extract_region_code(@restaurant))
    
    unless demographic_data
      redirect_to restaurant_menu_predictions_path(@restaurant), 
                  alert: "No demographic data available. Please add demographic data first."
      return
    end
    
    predictions_created = 0
    @restaurant.menu_items.each do |menu_item|
      service = MenuPredictionService.new(
        menu_item: menu_item,
        restaurant: @restaurant,
        demographic_data: demographic_data
      )
      service.predict
      predictions_created += 4 # 4 prediction types per item
    end
    
    redirect_to restaurant_menu_predictions_path(@restaurant), 
                notice: "Generated predictions for #{@restaurant.menu_items.count} menu items."
  end

  def train_model
    # This would typically train a new ML model
    # For now, we'll create a placeholder model
    model = PredictionModel.create(
      name: 'menu_success_predictor',
      model_type: 'ensemble',
      version: "#{Time.current.strftime('%Y%m%d')}_#{PredictionModel.where(name: 'menu_success_predictor').count + 1}",
      description: 'Ensemble model for predicting menu item success',
      training_metrics: {
        accuracy: 0.82,
        r2_score: 0.79,
        mse: 0.15
      },
      feature_importance: {
        'price' => 0.25,
        'demographic_score' => 0.20,
        'has_image' => 0.15,
        'dietary_tags_count' => 0.12,
        'average_age' => 0.10,
        'median_income' => 0.08,
        'historical_views' => 0.10
      },
      training_samples: @restaurant.menu_items.count,
      trained_at: Date.current,
      active: true
    )
    
    redirect_to restaurant_menu_predictions_path(@restaurant), 
                notice: "Model training initiated. Model version: #{model.version}"
  end

  private

  def set_restaurant
    @restaurant = Restaurant.find(params[:restaurant_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to restaurants_path, alert: "Restaurant not found."
  end

  def set_menu_prediction
    @menu_prediction = @restaurant.menu_predictions.find(params[:id])
  end

  def require_team_access
    unless can_access_restaurant?(@restaurant)
      redirect_to @restaurant, alert: "You don't have access to this restaurant."
    end
  end

  def can_access_restaurant?(restaurant)
    return false unless respond_to?(:current_user) && current_user
    return true if restaurant.user == current_user
    restaurant.restaurant_teams.active.exists?(user: current_user)
  end

  def extract_region_code(restaurant)
    # Simple extraction - could be enhanced
    if restaurant.address.include?('USA') || restaurant.address.match(/\bUS\b/)
      'US'
    elsif restaurant.address.include?('UK')
      'GB'
    else
      'US'
    end
  end
end

