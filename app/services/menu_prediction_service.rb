class MenuPredictionService
  attr_reader :menu_item, :restaurant, :demographic_data, :model

  def initialize(menu_item:, restaurant:, demographic_data: nil, model: nil)
    @menu_item = menu_item
    @restaurant = restaurant
    @demographic_data = demographic_data || find_demographic_data
    @model = model || PredictionModel.active.latest.first
  end

  # Generate predictions for a menu item
  def predict
    return nil unless @demographic_data.present? && @model.present?

    features = extract_features
    predictions = calculate_predictions(features)
    
    # Store predictions
    predictions.map do |prediction_type, result|
      MenuPrediction.create(
        menu_item: @menu_item,
        restaurant: @restaurant,
        demographic_data: @demographic_data,
        prediction_type: prediction_type,
        predicted_value: result[:value],
        confidence_score: result[:confidence],
        features: features,
        prediction_details: result[:details],
        model_version: @model.version
      )
    end
  end

  # Predict success score (0-1)
  def predict_success_score
    features = extract_features
    result = calculate_prediction('success_score', features)
    
    MenuPrediction.create(
      menu_item: @menu_item,
      restaurant: @restaurant,
      demographic_data: @demographic_data,
      prediction_type: 'success_score',
      predicted_value: result[:value],
      confidence_score: result[:confidence],
      features: features,
      prediction_details: result[:details],
      model_version: @model&.version
    )
  end

  # Predict popularity score (0-10)
  def predict_popularity_score
    features = extract_features
    result = calculate_prediction('popularity_score', features)
    
    MenuPrediction.create(
      menu_item: @menu_item,
      restaurant: @restaurant,
      demographic_data: @demographic_data,
      prediction_type: 'popularity_score',
      predicted_value: result[:value],
      confidence_score: result[:confidence],
      features: features,
      prediction_details: result[:details],
      model_version: @model&.version
    )
  end

  # Predict revenue potential
  def predict_revenue_potential
    features = extract_features
    result = calculate_prediction('revenue_potential', features)
    
    MenuPrediction.create(
      menu_item: @menu_item,
      restaurant: @restaurant,
      demographic_data: @demographic_data,
      prediction_type: 'revenue_potential',
      predicted_value: result[:value],
      confidence_score: result[:confidence],
      features: features,
      prediction_details: result[:details],
      model_version: @model&.version
    )
  end

  private

  def find_demographic_data
    # Try to find demographic data for restaurant's location
    if @restaurant.locations.any?
      location = @restaurant.locations.first
      DemographicData.find_by(location: location) ||
        DemographicData.find_by(region_code: extract_region_code(location))
    else
      DemographicData.find_by(region_code: extract_region_code(@restaurant))
    end
  end

  def extract_region_code(location_or_restaurant)
    # Extract region code from address or use default
    address = location_or_restaurant.respond_to?(:address) ? location_or_restaurant.address : location_or_restaurant.to_s
    # Simple extraction - could be enhanced with geocoding
    if address.include?('USA') || address.match(/\bUS\b/)
      'US'
    elsif address.include?('UK') || address.include?('United Kingdom')
      'GB'
    elsif address.include?('EU') || address.include?('Europe')
      'EU'
    else
      'US' # Default
    end
  end

  def extract_features
    {
      # Menu item features
      price: @menu_item.price || 0,
      has_image: @menu_item.image.attached? ? 1 : 0,
      dietary_tags_count: @menu_item.dietary_tags&.count || 0,
      has_allergens: @menu_item.has_allergens? ? 1 : 0,
      category: @menu_item.category || 'uncategorized',
      description_length: @menu_item.description&.length || 0,
      
      # Dietary preferences match
      vegan: @menu_item.dietary_tags&.include?('vegan') ? 1 : 0,
      vegetarian: @menu_item.dietary_tags&.include?('vegetarian') ? 1 : 0,
      gluten_free: @menu_item.dietary_tags&.include?('gluten-free') ? 1 : 0,
      organic: @menu_item.dietary_tags&.include?('organic') ? 1 : 0,
      
      # Demographic features
      average_age: @demographic_data&.average_age || 35,
      median_income: @demographic_data&.median_income || 50000,
      demographic_score: @demographic_data&.demographic_score || 50,
      primary_cultural: @demographic_data&.primary_cultural_group || 'general',
      
      # Historical performance (if available)
      historical_views: @menu_item.menu_item_analytics.sum(:views) || 0,
      historical_clicks: @menu_item.menu_item_analytics.sum(:clicks) || 0,
      historical_orders: @menu_item.menu_item_analytics.sum(:orders) || 0,
      historical_revenue: @menu_item.menu_item_analytics.sum(:revenue) || 0,
      
      # Restaurant features
      restaurant_menu_size: @restaurant.menu_items.count,
      restaurant_avg_price: @restaurant.menu_items.average(:price)&.round(2) || 0
    }
  end

  def calculate_predictions(features)
    {
      'success_score' => calculate_prediction('success_score', features),
      'popularity_score' => calculate_prediction('popularity_score', features),
      'revenue_potential' => calculate_prediction('revenue_potential', features),
      'dietary_fit' => calculate_prediction('dietary_fit', features)
    }
  end

  def calculate_prediction(type, features)
    # Simplified ML prediction using rule-based approach
    # In production, this would call a trained ML model
    
    case type
    when 'success_score'
      calculate_success_score(features)
    when 'popularity_score'
      calculate_popularity_score(features)
    when 'revenue_potential'
      calculate_revenue_potential(features)
    when 'dietary_fit'
      calculate_dietary_fit(features)
    else
      { value: 0.5, confidence: 0.5, details: {} }
    end
  end

  def calculate_success_score(features)
    score = 0.5 # Base score
    
    # Price factor (moderate pricing performs better)
    price_factor = if features[:price] > 0 && features[:restaurant_avg_price] > 0
      price_ratio = features[:price] / features[:restaurant_avg_price]
      if price_ratio >= 0.8 && price_ratio <= 1.2
        0.1 # Good price range
      elsif price_ratio > 1.5
        -0.1 # Too expensive
      else
        0.05
      end
    else
      0
    end
    
    # Image factor
    image_factor = features[:has_image] == 1 ? 0.15 : -0.1
    
    # Dietary match factor
    dietary_match = calculate_dietary_match(features)
    
    # Demographic fit
    age_factor = calculate_age_fit(features)
    income_factor = calculate_income_fit(features)
    
    # Historical performance (if available)
    historical_factor = if features[:historical_views] > 0
      views_score = [features[:historical_views] / 100.0, 1.0].min
      clicks_score = [features[:historical_clicks] / 50.0, 1.0].min
      orders_score = [features[:historical_orders] / 20.0, 1.0].min
      (views_score * 0.3 + clicks_score * 0.3 + orders_score * 0.4) * 0.2
    else
      0
    end
    
    score += price_factor + image_factor + dietary_match + age_factor + income_factor + historical_factor
    score = [[score, 0.0].max, 1.0].min # Clamp between 0 and 1
    
    confidence = calculate_confidence(features)
    
    {
      value: score,
      confidence: confidence,
      details: {
        recommendation: generate_recommendation(score, features),
        risk_factors: identify_risk_factors(features),
        strengths: identify_strengths(features)
      }
    }
  end

  def calculate_popularity_score(features)
    # Convert success score to 0-10 scale
    success_result = calculate_success_score(features)
    popularity = success_result[:value] * 10
    
    {
      value: popularity,
      confidence: success_result[:confidence],
      details: success_result[:details]
    }
  end

  def calculate_revenue_potential(features)
    # Estimate monthly revenue based on popularity and price
    success_result = calculate_success_score(features)
    base_revenue = features[:price] * 30 # Assume 1 order per day
    
    # Adjust based on success score
    estimated_revenue = base_revenue * success_result[:value] * 2
    
    {
      value: estimated_revenue,
      confidence: success_result[:confidence] * 0.8, # Lower confidence for revenue
      details: {
        estimated_daily_orders: (success_result[:value] * 2).round(1),
        estimated_monthly_orders: (success_result[:value] * 60).round(0),
        recommendation: success_result[:details][:recommendation]
      }
    }
  end

  def calculate_dietary_fit(features)
    dietary_match = calculate_dietary_match(features)
    age_fit = calculate_age_fit(features)
    income_fit = calculate_income_fit(features)
    
    fit_score = 0.5 + dietary_match + (age_fit * 0.3) + (income_fit * 0.2)
    fit_score = [[fit_score, 0.0].max, 1.0].min
    
    {
      value: fit_score,
      confidence: calculate_confidence(features),
      details: {
        dietary_match: dietary_match,
        age_fit: age_fit,
        income_fit: income_fit
      }
    }
  end

  def calculate_dietary_match(features)
    return 0 unless @demographic_data&.dietary_preferences.present?
    
    match_score = 0.0
    preferences = @demographic_data.dietary_preferences
    
    preferences.each do |pref, percentage|
      case pref.downcase
      when 'vegan'
        match_score += 0.1 if features[:vegan] == 1
      when 'vegetarian'
        match_score += 0.08 if features[:vegetarian] == 1
      when 'gluten-free', 'gluten free'
        match_score += 0.08 if features[:gluten_free] == 1
      when 'organic'
        match_score += 0.05 if features[:organic] == 1
      end
    end
    
    [match_score, 0.2].min
  end

  def calculate_age_fit(features)
    avg_age = features[:average_age]
    return 0 unless avg_age
    
    # Younger demographics prefer different items
    # This is a simplified heuristic
    if avg_age < 30
      # Younger crowd - prefer trendy, affordable items
      features[:price] < 15 ? 0.1 : 0
    elsif avg_age > 50
      # Older crowd - prefer traditional, quality items
      features[:price] > 10 ? 0.1 : 0
    else
      0.05 # Middle-aged - balanced
    end
  end

  def calculate_income_fit(features)
    median_income = features[:median_income]
    return 0 unless median_income
    
    price = features[:price]
    return 0 unless price > 0
    
    # Higher income areas can support higher prices
    income_to_price_ratio = median_income / (price * 100)
    
    if income_to_price_ratio > 3
      0.1 # Good fit - affordable for demographic
    elsif income_to_price_ratio > 2
      0.05 # Moderate fit
    else
      -0.05 # Poor fit - too expensive
    end
  end

  def calculate_confidence(features)
    confidence = 0.5
    
    # Increase confidence with more data
    confidence += 0.2 if features[:historical_views] > 0
    confidence += 0.1 if @demographic_data&.verified?
    confidence += 0.1 if features[:has_image] == 1
    confidence += 0.1 if features[:description_length] > 50
    
    [[confidence, 0.0].max, 1.0].min
  end

  def generate_recommendation(score, features)
    if score >= 0.7
      "This item has high success potential based on local demographics."
    elsif score >= 0.5
      "This item shows moderate potential. Consider optimizing price or description."
    else
      "This item may face challenges. Review pricing, dietary tags, or target demographic."
    end
  end

  def identify_risk_factors(features)
    risks = []
    
    risks << "No image available" if features[:has_image] == 0
    risks << "Price may be too high for local income" if features[:median_income] > 0 && features[:price] > (features[:median_income] / 2000)
    risks << "Limited dietary information" if features[:dietary_tags_count] == 0
    risks << "No historical performance data" if features[:historical_views] == 0
    
    risks
  end

  def identify_strengths(features)
    strengths = []
    
    strengths << "Has image" if features[:has_image] == 1
    strengths << "Good price point" if features[:price] > 0 && features[:restaurant_avg_price] > 0 && 
                                       (features[:price] / features[:restaurant_avg_price] >= 0.8 && 
                                        features[:price] / features[:restaurant_avg_price] <= 1.2)
    strengths << "Strong dietary tags" if features[:dietary_tags_count] >= 3
    strengths << "Proven performance" if features[:historical_orders] > 10
    
    strengths
  end
end

