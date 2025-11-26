require 'net/http'
require 'json'
require 'uri'

class NutritionApiService
  attr_reader :menu_item, :errors

  def initialize(menu_item)
    @menu_item = menu_item
    @errors = []
  end

  # Fetch nutrition data from Edamam API
  def fetch_nutrition
    return { success: false, error: "Edamam API credentials not configured" } unless api_configured?

    query = build_query
    return { success: false, error: "Cannot build query: menu item needs name or ingredients" } unless query.present?

    begin
      uri = URI("https://api.edamam.com/api/nutrition-details")
      params = {
        app_id: ENV['EDAMAM_APP_ID'],
        app_key: ENV['EDAMAM_APP_KEY'],
        ingr: query
      }
      uri.query = URI.encode_www_form(params)

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.read_timeout = 10

      request = Net::HTTP::Get.new(uri)
      response = http.request(request)

      if response.code == '200'
        data = JSON.parse(response.body)
        nutrition_data = extract_nutrition_data(data)
        { success: true, data: nutrition_data, raw_data: data }
      else
        error_message = "API returned status #{response.code}"
        begin
          error_data = JSON.parse(response.body)
          error_message = error_data['error'] || error_data['message'] || error_message
        rescue
          error_message = response.body if response.body.present?
        end
        { success: false, error: error_message }
      end
    rescue Net::TimeoutError => e
      { success: false, error: "Request timeout: #{e.message}" }
    rescue JSON::ParserError => e
      { success: false, error: "Failed to parse API response: #{e.message}" }
    rescue => e
      { success: false, error: "API request failed: #{e.message}" }
    end
  end

  # Alternative: Use Edamam's natural language endpoint
  def fetch_nutrition_natural_language
    return { success: false, error: "Edamam API credentials not configured" } unless api_configured?

    query = build_natural_language_query
    return { success: false, error: "Cannot build query" } unless query.present?

    begin
      uri = URI("https://api.edamam.com/api/nutrition-data")
      params = {
        app_id: ENV['EDAMAM_APP_ID'],
        app_key: ENV['EDAMAM_APP_KEY'],
        ingr: query
      }
      uri.query = URI.encode_www_form(params)

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.read_timeout = 10

      request = Net::HTTP::Get.new(uri)
      response = http.request(request)

      if response.code == '200'
        data = JSON.parse(response.body)
        nutrition_data = extract_nutrition_data(data)
        { success: true, data: nutrition_data, raw_data: data }
      else
        error_message = "API returned status #{response.code}"
        begin
          error_data = JSON.parse(response.body)
          error_message = error_data['error'] || error_data['message'] || error_message
        rescue
          error_message = response.body if response.body.present?
        end
        { success: false, error: error_message }
      end
    rescue => e
      { success: false, error: "API request failed: #{e.message}" }
    end
  end

  private

  def api_configured?
    ENV['EDAMAM_APP_ID'].present? && ENV['EDAMAM_APP_KEY'].present?
  end

  def build_query
    # Try to build query from ingredients first
    if menu_item.ingredients.any?
      ingredients_list = menu_item.ingredients.map do |ingredient|
        quantity = menu_item.menu_item_ingredients.find_by(ingredient: ingredient)&.quantity
        if quantity.present?
          "#{quantity} #{ingredient.name}"
        else
          ingredient.name
        end
      end
      return ingredients_list.join(', ')
    end

    # Fallback to menu item name and description
    query_parts = [menu_item.name]
    query_parts << menu_item.description if menu_item.description.present?
    query_parts.join(' ')
  end

  def build_natural_language_query
    # Build a natural language description for the API
    query_parts = []
    
    if menu_item.ingredients.any?
      ingredients_list = menu_item.ingredients.map do |ingredient|
        quantity = menu_item.menu_item_ingredients.find_by(ingredient: ingredient)&.quantity
        if quantity.present?
          "#{quantity} #{ingredient.name}"
        else
          ingredient.name
        end
      end
      query_parts << ingredients_list.join(', ')
    else
      query_parts << menu_item.name
      query_parts << menu_item.description if menu_item.description.present?
    end
    
    query_parts.join(' ')
  end

  def extract_nutrition_data(api_response)
    # Extract nutrition data from Edamam API response
    # The response structure may vary, so we handle multiple formats
    nutrition = {
      calories: nil,
      protein: nil,
      carbs: nil,
      fat: nil,
      fiber: nil,
      sugar: nil,
      sodium: nil,
      cholesterol: nil
    }

    # Edamam API returns nutrients in different formats
    if api_response['totalNutrients']
      nutrients = api_response['totalNutrients']
      
      nutrition[:calories] = api_response['calories']&.round
      nutrition[:protein] = nutrients.dig('PROCNT', 'quantity')&.round(2)
      nutrition[:carbs] = nutrients.dig('CHOCDF', 'quantity')&.round(2)
      nutrition[:fat] = nutrients.dig('FAT', 'quantity')&.round(2)
      nutrition[:fiber] = nutrients.dig('FIBTG', 'quantity')&.round(2)
      nutrition[:sugar] = nutrients.dig('SUGAR', 'quantity')&.round(2)
      nutrition[:sodium] = (nutrients.dig('NA', 'quantity') || 0)&.round
      nutrition[:cholesterol] = (nutrients.dig('CHOLE', 'quantity') || 0)&.round
    elsif api_response['totalDaily']
      # Alternative format
      nutrition[:calories] = api_response['calories']&.round
      nutrition[:protein] = api_response['totalNutrients']&.dig('PROCNT', 'quantity')&.round(2)
      nutrition[:carbs] = api_response['totalNutrients']&.dig('CHOCDF', 'quantity')&.round(2)
      nutrition[:fat] = api_response['totalNutrients']&.dig('FAT', 'quantity')&.round(2)
    end

    nutrition
  end
end

