class Restaurants::AnalyticsController < ApplicationController
  before_action :set_restaurant
  before_action :require_authentication
  before_action :authorize_owner

  def index
    # QR Scan Analytics
    @total_scans = @restaurant.qr_scans.count
    @scans_today = @restaurant.qr_scans.where('scanned_at >= ?', Time.current.beginning_of_day).count
    @scans_this_week = @restaurant.qr_scans.where('scanned_at >= ?', 1.week.ago).count
    @scans_this_month = @restaurant.qr_scans.where('scanned_at >= ?', 1.month.ago).count
    
    # Scan trends (last 30 days) - SQLite compatible
    scans_by_date_raw = @restaurant.qr_scans
      .where('scanned_at >= ?', 30.days.ago)
      .group("date(scanned_at)")
      .count
    
    @scans_by_date = {}
    scans_by_date_raw.each do |date_str, count|
      date = Date.parse(date_str) rescue Date.today
      @scans_by_date[date.strftime('%b %d')] = count
    end
    @scans_by_date = @scans_by_date.sort_by { |k, v| k }.to_h
    
    # Most popular menu items (by views)
    @popular_items = @restaurant.menu_items
      .joins(:menu_item_analytics)
      .select('menu_items.*, SUM(menu_item_analytics.views) as total_views, SUM(menu_item_analytics.clicks) as total_clicks, SUM(menu_item_analytics.orders) as total_orders')
      .group('menu_items.id')
      .order('total_views DESC')
      .limit(10)
    
    # Menu item analytics summary
    @total_menu_views = @restaurant.menu_items.joins(:menu_item_analytics).sum('menu_item_analytics.views') || 0
    @total_menu_clicks = @restaurant.menu_items.joins(:menu_item_analytics).sum('menu_item_analytics.clicks') || 0
    @total_menu_orders = @restaurant.menu_items.joins(:menu_item_analytics).sum('menu_item_analytics.orders') || 0
    
    # Scan locations (if location tracking is available)
    @scans_by_location = {}
    if @restaurant.respond_to?(:locations) && @restaurant.locations.any?
      @restaurant.locations.each do |location|
        # For now, just track by restaurant - location-specific tracking can be added later
        # scan_count = @restaurant.qr_scans.count # Simplified for now
        # @scans_by_location[location.name] = scan_count if scan_count > 0
      end
    end
    
    # Peak scan times (by hour of day) - SQLite compatible
    scans_by_hour_raw = @restaurant.qr_scans
      .where('scanned_at >= ?', 30.days.ago)
      .group("strftime('%H', scanned_at)")
      .count
    
    @scans_by_hour = {}
    scans_by_hour_raw.each do |hour_str, count|
      hour = hour_str.to_i
      time_str = Time.parse("#{hour}:00").strftime('%l %p').strip
      @scans_by_hour[time_str] = count
    end
    @scans_by_hour = @scans_by_hour.sort_by { |k, v| k }.to_h
    
    # Device types (if user_agent is stored)
    @device_types = {}
    @restaurant.qr_scans.where('scanned_at >= ?', 30.days.ago).find_each do |scan|
      if scan.user_agent.present?
        device = detect_device_type(scan.user_agent)
        @device_types[device] = (@device_types[device] || 0) + 1
      end
    end
  end

  def menu_item
    @menu_item = @restaurant.menu_items.find(params[:menu_item_id])
    
    # Daily analytics for this item
    @daily_analytics = @menu_item.menu_item_analytics
      .where('date >= ?', 30.days.ago)
      .order(:date)
    
    # Summary stats
    @total_views = @menu_item.menu_item_analytics.sum(:views) || 0
    @total_clicks = @menu_item.menu_item_analytics.sum(:clicks) || 0
    @total_orders = @menu_item.menu_item_analytics.sum(:orders) || 0
    
    # Conversion rates
    @view_to_click_rate = @total_views > 0 ? (@total_clicks.to_f / @total_views * 100).round(2) : 0
    @click_to_order_rate = @total_clicks > 0 ? (@total_orders.to_f / @total_clicks * 100).round(2) : 0
  end

  private

  def set_restaurant
    @restaurant = Restaurant.find(params[:restaurant_id])
  end

  def authorize_owner
    unless restaurant_owner?(@restaurant)
      redirect_to @restaurant, alert: "You are not authorized to view analytics."
    end
  end

  def detect_device_type(user_agent)
    return 'Unknown' if user_agent.blank?
    
    ua = user_agent.downcase
    if ua.include?('mobile') || ua.include?('android') || ua.include?('iphone')
      'Mobile'
    elsif ua.include?('tablet') || ua.include?('ipad')
      'Tablet'
    else
      'Desktop'
    end
  end
end

