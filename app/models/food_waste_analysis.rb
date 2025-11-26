class FoodWasteAnalysis
  attr_reader :restaurant, :period_days

  def initialize(restaurant, period_days: 30)
    @restaurant = restaurant
    @period_days = period_days
  end

  # Get unpopular menu items (low views, clicks, or orders)
  def unpopular_items(threshold: 5)
    end_date = Date.current
    start_date = end_date - period_days.days

    menu_items_with_stats = restaurant.menu_items.map do |item|
      stats = item_statistics(item, start_date, end_date)
      {
        menu_item: item,
        views: stats[:total_views],
        clicks: stats[:total_clicks],
        orders: stats[:total_orders],
        revenue: stats[:total_revenue],
        last_viewed: stats[:last_viewed],
        days_since_view: stats[:days_since_view],
        popularity_score: calculate_popularity_score(stats)
      }
    end

    # Filter items below threshold
    menu_items_with_stats.select { |item| item[:popularity_score] < threshold }
                         .sort_by { |item| item[:popularity_score] }
  end

  # Get items with no activity
  def items_with_no_activity
    end_date = Date.current
    start_date = end_date - period_days.days

    restaurant.menu_items.select do |item|
      stats = item_statistics(item, start_date, end_date)
      stats[:total_views].zero? && stats[:total_clicks].zero? && stats[:total_orders].zero?
    end
  end

  # Get items with declining popularity
  def declining_items
    end_date = Date.current
    start_date = end_date - period_days.days
    midpoint = start_date + (period_days / 2).days

    restaurant.menu_items.map do |item|
      first_half = item_statistics(item, start_date, midpoint)
      second_half = item_statistics(item, midpoint, end_date)

      first_score = calculate_popularity_score(first_half)
      second_score = calculate_popularity_score(second_half)

      decline_percentage = first_score > 0 ? ((first_score - second_score) / first_score * 100).round(2) : 0

      {
        menu_item: item,
        first_half_score: first_score,
        second_half_score: second_score,
        decline_percentage: decline_percentage,
        current_stats: second_half
      }
    end.select { |item| item[:decline_percentage] > 20 } # More than 20% decline
      .sort_by { |item| -item[:decline_percentage] }
  end

  # Get waste risk items (items likely to cause waste)
  def waste_risk_items
    unpopular = unpopular_items(threshold: 3)
    no_activity = items_with_no_activity
    declining = declining_items.map { |d| d[:menu_item] }

    # Combine and deduplicate
    all_items = (unpopular.map { |u| u[:menu_item] } + no_activity + declining).uniq

    all_items.map do |item|
      stats = item_statistics(item, Date.current - period_days.days, Date.current)
      {
        menu_item: item,
        risk_level: calculate_risk_level(stats),
        reasons: waste_risk_reasons(item, stats),
        recommendations: generate_recommendations(item, stats)
      }
    end.sort_by { |item| risk_level_score(item[:risk_level]) }
  end

  # Get summary statistics
  def summary
    end_date = Date.current
    start_date = end_date - period_days.days

    total_items = restaurant.menu_items.count
    active_items = restaurant.menu_items.count { |item| item_statistics(item, start_date, end_date)[:total_views] > 0 }
    inactive_items = total_items - active_items

    {
      total_menu_items: total_items,
      active_items: active_items,
      inactive_items: inactive_items,
      inactive_percentage: total_items > 0 ? ((inactive_items.to_f / total_items) * 100).round(2) : 0,
      period_days: period_days,
      waste_risk_count: waste_risk_items.count
    }
  end

  private

  def item_statistics(menu_item, start_date, end_date)
    analytics = MenuItemAnalytics.where(menu_item: menu_item)
                                 .by_date_range(start_date, end_date)

    last_analytics = analytics.order(date: :desc).first

    {
      total_views: analytics.sum(:views) || 0,
      total_clicks: analytics.sum(:clicks) || 0,
      total_orders: analytics.sum(:orders) || 0,
      total_revenue: analytics.sum(:revenue) || 0,
      last_viewed: last_analytics&.date,
      days_since_view: last_analytics ? (Date.current - last_analytics.date).to_i : nil
    }
  end

  def calculate_popularity_score(stats)
    # Weighted score: views (1x), clicks (2x), orders (5x)
    (stats[:total_views] * 1) + 
    (stats[:total_clicks] * 2) + 
    (stats[:total_orders] * 5)
  end

  def calculate_risk_level(stats)
    return 'high' if stats[:total_views].zero? && stats[:days_since_view].nil?
    return 'high' if stats[:days_since_view] && stats[:days_since_view] > period_days
    return 'medium' if stats[:total_orders].zero? && stats[:total_views] < 10
    return 'low' if stats[:total_orders] > 0 && stats[:total_views] > 20
    'medium'
  end

  def risk_level_score(level)
    { 'high' => 3, 'medium' => 2, 'low' => 1 }[level] || 0
  end

  def waste_risk_reasons(menu_item, stats)
    reasons = []
    
    reasons << "No views in the last #{period_days} days" if stats[:total_views].zero?
    reasons << "No orders in the last #{period_days} days" if stats[:total_orders].zero?
    reasons << "Last viewed #{stats[:days_since_view]} days ago" if stats[:days_since_view] && stats[:days_since_view] > 7
    reasons << "Very low popularity score" if calculate_popularity_score(stats) < 5
    reasons << "Low conversion rate" if stats[:total_views] > 0 && (stats[:total_clicks].to_f / stats[:total_views]) < 0.1

    reasons
  end

  def generate_recommendations(menu_item, stats)
    recommendations = []
    
    if stats[:total_views].zero?
      recommendations << "Consider removing this item from the menu"
      recommendations << "Or promote it with special offers"
    elsif stats[:total_orders].zero? && stats[:total_views] > 0
      recommendations << "Item is viewed but not ordered - review pricing or description"
      recommendations << "Consider adding to promotions"
    elsif stats[:days_since_view] && stats[:days_since_view] > 14
      recommendations << "Item hasn't been viewed recently - consider seasonal removal"
      recommendations << "Update description or add to featured items"
    else
      recommendations << "Monitor closely - low engagement detected"
      recommendations << "Consider seasonal availability adjustments"
    end

    recommendations
  end
end

