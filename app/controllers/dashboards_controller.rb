class DashboardsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_restaurant
  before_action :authorize_owner

  def show
    @analytics = calculate_analytics
  end

  private

  def set_restaurant
    @restaurant = Restaurant.find(params[:restaurant_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to restaurants_path, alert: "Restaurant not found."
  end

  def authorize_owner
    unless @restaurant.user == current_user
      redirect_to @restaurant, alert: "You can only view the dashboard for your own restaurants."
      return
    end
  end

  def calculate_analytics
    {
      # QR Scan Analytics
      total_scans: @restaurant.qr_scans.count,
      scans_today: @restaurant.qr_scans.today.count,
      scans_this_week: @restaurant.qr_scans.this_week.count,
      scans_this_month: @restaurant.qr_scans.this_month.count,
      scans_by_day: scans_by_day,
      scans_by_hour: scans_by_hour,
      
      # Menu Performance
      total_menu_items: @restaurant.menu_items.count,
      average_price: @restaurant.menu_items.average(:price)&.round(2) || 0,
      menu_value: @restaurant.menu_items.sum(:price),
      
      # Popular Items (based on views - we'll track this later)
      popular_items: popular_items,
      
      # Growth Metrics
      scan_growth: scan_growth,
      recent_activity: recent_activity
    }
  end

  def scans_by_day
    # SQLite-compatible date grouping
    @restaurant.qr_scans
      .where('scanned_at >= ?', 30.days.ago)
      .group("date(scanned_at)")
      .count
      .sort
  end

  def scans_by_hour
    # SQLite-compatible hour grouping
    @restaurant.qr_scans
      .where('scanned_at >= ?', 7.days.ago)
      .group("strftime('%H', scanned_at)")
      .count
      .sort
  end

  def popular_items
    # For now, return menu items ordered by creation (we can add view tracking later)
    @restaurant.menu_items
      .order(created_at: :desc)
      .limit(10)
      .map do |item|
        {
          name: item.name,
          price: item.price,
          description: item.description,
          dietary_tags: item.dietary_tags
        }
      end
  end

  def scan_growth
    last_week = @restaurant.qr_scans.where('scanned_at >= ? AND scanned_at < ?', 
                                           1.week.ago, Date.today.beginning_of_day).count
    this_week = @restaurant.qr_scans.this_week.count
    
    if last_week > 0
      growth = ((this_week - last_week).to_f / last_week * 100).round(1)
    else
      growth = this_week > 0 ? 100 : 0
    end
    
    {
      last_week: last_week,
      this_week: this_week,
      growth_percentage: growth
    }
  end

  def recent_activity
    @restaurant.qr_scans
      .order(scanned_at: :desc)
      .limit(10)
      .map do |scan|
        {
          scanned_at: scan.scanned_at,
          ip_address: scan.ip_address,
          user_agent: scan.user_agent&.truncate(50)
        }
      end
  end
end

