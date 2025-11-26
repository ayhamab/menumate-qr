class Admin::DietaryTrendsController < ApplicationController
  before_action :authenticate_user!
  before_action :check_admin_access
  before_action :set_dietary_trend, only: [:show]

  # GET /admin/dietary_trends
  def index
    @dietary_trends = DietaryTrend.recent.limit(100)
    @dietary_trends = @dietary_trends.by_tag(params[:dietary_tag]) if params[:dietary_tag].present?
    @dietary_trends = @dietary_trends.by_region(params[:region]) if params[:region].present?
    
    if params[:start_date].present? && params[:end_date].present?
      @dietary_trends = @dietary_trends.by_date_range(Date.parse(params[:start_date]), Date.parse(params[:end_date]))
    end
  end

  # GET /admin/dietary_trends/:id
  def show
  end

  # POST /admin/dietary_trends/generate_report
  def generate_report
    start_date = params[:start_date] ? Date.parse(params[:start_date]) : 30.days.ago
    end_date = params[:end_date] ? Date.parse(params[:end_date]) : Date.today
    region = params[:region]

    trends = DietaryTrend.generate_trend_report(start_date: start_date, end_date: end_date, region: region)

    redirect_to admin_dietary_trends_path(start_date: start_date, end_date: end_date, region: region),
                notice: "Generated trend report with #{trends.count} dietary trends."
  end

  # GET /admin/dietary_trends/dashboard
  def dashboard
    @top_trends = DietaryTrend.top_trends(limit: 10)
    @growth_leaders = DietaryTrend.growth_leaders(limit: 10)
    @recent_trends = DietaryTrend.recent.limit(20)
    
    # Aggregate statistics
    @total_menu_items = MenuItem.count
    @total_restaurants = Restaurant.count
    @unique_dietary_tags = MenuItem.all.pluck(:dietary_tags).flatten.compact.uniq.count
    
    # Regional breakdown (if restaurants have addresses)
    @regions = Restaurant.where.not(address: nil)
                        .pluck(:address)
                        .map { |addr| addr.split(',').last&.strip }
                        .compact
                        .uniq
                        .first(10)
  end

  private

  def set_dietary_trend
    @dietary_trend = DietaryTrend.find(params[:id])
  end

  def check_admin_access
    # For now, allow any authenticated user. In production, add admin role check
    unless user_signed_in?
      redirect_to root_path, alert: "Admin access required."
      return
    end
  end
end
