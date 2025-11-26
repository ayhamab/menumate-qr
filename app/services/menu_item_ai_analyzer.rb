require 'openai'

class MenuItemAiAnalyzer
  attr_reader :menu_item, :client

  def initialize(menu_item)
    @menu_item = menu_item
    @client = OpenAI::Client.new(access_token: ENV['OPENAI_API_KEY'])
  end

  def analyze
    return error_response("OpenAI API key not configured") unless ENV['OPENAI_API_KEY'].present?

    prompt = build_analysis_prompt
    
    begin
      response = @client.chat(
        parameters: {
          model: "gpt-4o-mini", # Using mini for cost efficiency
          messages: [
            {
              role: "system",
              content: "You are a food menu expert specializing in dietary information, allergens, and menu descriptions. Provide accurate, helpful suggestions for restaurant menu items."
            },
            {
              role: "user",
              content: prompt
            }
          ],
          temperature: 0.3, # Lower temperature for more consistent results
          max_tokens: 500
        }
      )

      parse_ai_response(response)
    rescue => e
      error_response("AI analysis failed: #{e.message}")
    end
  end

  private

  def build_analysis_prompt
    <<~PROMPT
      Analyze this restaurant menu item and provide suggestions:

      Item Name: #{menu_item.name}
      Current Description: #{menu_item.description || 'No description provided'}
      Current Dietary Tags: #{menu_item.dietary_tags&.join(', ') || 'None'}
      Current Allergens: #{menu_item.allergens&.join(', ') || 'None'}
      Category: #{menu_item.category || 'Not specified'}

      Please provide:
      1. Suggested dietary tags (from: vegetarian, vegan, gluten-free, dairy-free, nut-free, halal, kosher, low-carb, keto, paleo, organic, spicy)
      2. Suggested allergens (from: nuts, peanuts, shellfish, fish, eggs, milk, soy, wheat, sesame, sulfites)
      3. An improved, appetizing description (2-3 sentences, highlight key ingredients and preparation)

      Respond in JSON format:
      {
        "dietary_tags": ["tag1", "tag2"],
        "allergens": ["allergen1", "allergen2"],
        "description": "Improved description here",
        "confidence": "high|medium|low",
        "reasoning": "Brief explanation of suggestions"
      }
    PROMPT
  end

  def parse_ai_response(response)
    content = response.dig("choices", 0, "message", "content")
    
    return error_response("No response from AI") unless content.present?

    # Extract JSON from response (handle markdown code blocks)
    json_match = content.match(/\{[\s\S]*\}/)
    return error_response("Invalid response format") unless json_match

    begin
      suggestions = JSON.parse(json_match[0])
      
      {
        success: true,
        suggestions: {
          dietary_tags: normalize_tags(suggestions['dietary_tags'] || []),
          allergens: normalize_allergens(suggestions['allergens'] || []),
          description: suggestions['description']&.strip,
          confidence: suggestions['confidence'] || 'medium',
          reasoning: suggestions['reasoning']&.strip
        }
      }
    rescue JSON::ParserError => e
      error_response("Failed to parse AI response: #{e.message}")
    end
  end

  def normalize_tags(tags)
    # Common dietary tags from the form
    valid_tags = ['vegetarian', 'vegan', 'gluten-free', 'dairy-free', 'nut-free', 'halal', 'kosher', 'low-carb', 'keto', 'paleo', 'organic', 'spicy']
    tags.map(&:downcase)
        .map { |tag| tag.gsub(/\s+/, '-') }
        .select { |tag| valid_tags.include?(tag) }
        .uniq
  end

  def normalize_allergens(allergens)
    valid_allergens = MenuItem.common_allergens.keys.map(&:to_s)
    allergens.map(&:downcase)
             .map { |allergen| allergen.gsub(/\s+/, '-') }
             .select { |allergen| valid_allergens.include?(allergen) }
             .uniq
  end

  def error_response(message)
    {
      success: false,
      error: message,
      suggestions: nil
    }
  end
end

