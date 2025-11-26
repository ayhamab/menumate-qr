module LocationHelper
  # Calculate distance between two coordinates (Haversine formula)
  def distance_between(lat1, lon1, lat2, lon2)
    return nil if lat1.nil? || lon1.nil? || lat2.nil? || lon2.nil?
    
    # Earth's radius in kilometers
    earth_radius = 6371
    
    # Convert to radians
    d_lat = (lat2 - lat1) * Math::PI / 180
    d_lon = (lon2 - lon1) * Math::PI / 180
    
    # Haversine formula
    a = Math.sin(d_lat / 2) ** 2 +
        Math.cos(lat1 * Math::PI / 180) *
        Math.cos(lat2 * Math::PI / 180) *
        Math.sin(d_lon / 2) ** 2
    
    c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))
    
    # Distance in kilometers
    (earth_radius * c).round(2)
  end

  # Find nearest location to coordinates
  def find_nearest_location(restaurant, latitude, longitude, max_distance_km: 50)
    return nil if latitude.nil? || longitude.nil?
    
    locations = restaurant.locations.active.where.not(latitude: nil, longitude: nil)
    return nil if locations.empty?
    
    nearest = locations.min_by do |location|
      distance_between(latitude, longitude, location.latitude, location.longitude) || Float::INFINITY
    end
    
    distance = distance_between(latitude, longitude, nearest.latitude, nearest.longitude)
    
    # Return nearest if within max distance
    distance && distance <= max_distance_km ? nearest : nil
  end

  # Get location-specific menu items
  def location_menu_items(restaurant, location = nil)
    if location.present?
      # Show location-specific items + general items (no location)
      restaurant.menu_items.where(
        "(location_id = ? OR location_id IS NULL)",
        location.id
      )
    else
      # Show only general items (no location)
      restaurant.menu_items.where(location_id: nil)
    end
  end
end

