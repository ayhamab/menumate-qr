require 'csv'

class MenuItemCsvImporter
  attr_reader :restaurant, :csv_file, :errors, :imported_count

  def initialize(restaurant, csv_file)
    @restaurant = restaurant
    @csv_file = csv_file
    @errors = []
    @imported_count = 0
  end

  def import
    begin
      csv_data = CSV.read(@csv_file.path, headers: true, encoding: 'UTF-8')
      
      # Validate headers
      required_headers = ['name', 'price']
      missing_headers = required_headers - csv_data.headers.map(&:downcase)
      
      if missing_headers.any?
        return {
          success: false,
          errors: ["Missing required columns: #{missing_headers.join(', ')}"],
          imported: 0
        }
      end

      # Normalize headers (case-insensitive)
      normalized_headers = {}
      csv_data.headers.each do |header|
        normalized_headers[header.downcase.strip] = header
      end

      # Process each row
      csv_data.each_with_index do |row, index|
        row_number = index + 2 # +2 because index is 0-based and we skip header row
        
        begin
          menu_item = build_menu_item_from_row(row, normalized_headers)
          
          if menu_item.save
            @imported_count += 1
          else
            @errors << {
              row: row_number,
              name: row[normalized_headers['name']] || 'Unknown',
              errors: menu_item.errors.full_messages
            }
          end
        rescue => e
          @errors << {
            row: row_number,
            name: row[normalized_headers['name']] || 'Unknown',
            errors: ["Error processing row: #{e.message}"]
          }
        end
      end

      {
        success: @errors.empty? || @imported_count > 0,
        imported: @imported_count,
        errors: @errors
      }
    rescue CSV::MalformedCSVError => e
      {
        success: false,
        errors: [{ row: 0, name: 'CSV File', errors: ["Invalid CSV format: #{e.message}"] }],
        imported: 0
      }
    rescue => e
      {
        success: false,
        errors: [{ row: 0, name: 'CSV File', errors: ["Error reading CSV file: #{e.message}"] }],
        imported: 0
      }
    end
  end

  private

  def build_menu_item_from_row(row, normalized_headers)
    menu_item = @restaurant.menu_items.build

    # Required fields
    name_header = find_header(normalized_headers, ['name', 'item name', 'menu item'])
    price_header = find_header(normalized_headers, ['price', 'cost', 'amount'])
    
    menu_item.name = row[name_header]&.strip if name_header
    menu_item.price = parse_price(row[price_header]) if price_header

    # Optional fields
    description_header = find_header(normalized_headers, ['description', 'desc', 'details'])
    category_header = find_header(normalized_headers, ['category', 'section', 'type'])
    position_header = find_header(normalized_headers, ['position', 'order', 'sort order'])
    dietary_tags_header = find_header(normalized_headers, ['dietary_tags', 'dietary tags', 'tags', 'dietary'])
    allergens_header = find_header(normalized_headers, ['allergens', 'allergy', 'allergy info'])

    menu_item.description = row[description_header]&.strip if description_header
    menu_item.category = row[category_header]&.strip if category_header
    menu_item.position = row[position_header]&.to_i if position_header && row[position_header].present?

    # Parse dietary tags (comma or semicolon separated)
    if dietary_tags_header && row[dietary_tags_header].present?
      tags = parse_list(row[dietary_tags_header])
      menu_item.dietary_tags = tags
    end

    # Parse allergens (comma or semicolon separated)
    if allergens_header && row[allergens_header].present?
      allergens = parse_list(row[allergens_header])
      menu_item.allergens = allergens
    end

    menu_item
  end

  def find_header(normalized_headers, possible_names)
    possible_names.each do |name|
      return normalized_headers[name.downcase] if normalized_headers[name.downcase]
    end
    nil
  end

  def parse_price(price_string)
    return 0.0 if price_string.blank?
    
    # Remove currency symbols and whitespace
    cleaned = price_string.to_s.gsub(/[$€£¥,\s]/, '').strip
    
    # Handle different decimal separators
    cleaned = cleaned.gsub(',', '.') if cleaned.count(',') == 1 && cleaned.count('.') == 0
    
    # Extract number
    number = cleaned.scan(/[\d.]+/).first
    
    number ? number.to_f : 0.0
  end

  def parse_list(list_string)
    return [] if list_string.blank?
    
    # Split by comma or semicolon, strip whitespace, and filter empty values
    list_string.to_s.split(/[,;]/)
              .map(&:strip)
              .reject(&:blank?)
              .map(&:downcase)
  end
end

