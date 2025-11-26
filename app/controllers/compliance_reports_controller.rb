class ComplianceReportsController < ApplicationController
  before_action :set_restaurant
  before_action :require_team_access
  before_action :set_compliance_report, only: [:show, :share]

  def index
    @compliance_reports = @restaurant.compliance_reports.includes(:region).recent
    @restaurant_regions = @restaurant.restaurant_regions.active.includes(:region)
    @compliance_status = {}
    
    @restaurant_regions.each do |restaurant_region|
      @compliance_status[restaurant_region.region_id] = restaurant_region.compliance_status
    end
  end

  def show
    @region = @compliance_report.region
    @violations = @compliance_report.findings || []
    @recommendations = @compliance_report.recommendations || []
  end

  def create
    region = Region.find(params[:region_id]) if params[:region_id].present?
    
    checker = ComplianceChecker.new(restaurant: @restaurant, region: region)
    @compliance_report = checker.generate_report(@restaurant, region)
    
    redirect_to restaurant_compliance_report_path(@restaurant, @compliance_report), 
                notice: "Compliance report generated successfully."
  end

  def generate
    region = Region.find(params[:region_id]) if params[:region_id].present?
    
    checker = ComplianceChecker.new(restaurant: @restaurant, region: region)
    @compliance_report = checker.generate_report(@restaurant, region)
    
    redirect_to restaurant_compliance_report_path(@restaurant, @compliance_report), 
                notice: "Compliance report generated successfully."
  end

  def check_all
    # Check all menu items for all regions
    @restaurant.restaurant_regions.active.each do |restaurant_region|
      checker = ComplianceChecker.new(restaurant: @restaurant, region: restaurant_region.region)
      checker.check_restaurant(@restaurant, restaurant_region.region)
    end
    
    redirect_to restaurant_compliance_reports_path(@restaurant), 
                notice: "Compliance check completed for all regions."
  end

  def share
    @compliance_report.update(shared_with_restaurant: true, shared_at: Time.current)
    redirect_to restaurant_compliance_report_path(@restaurant, @compliance_report), 
                notice: "Report shared with restaurant team."
  end

  private

  def set_restaurant
    @restaurant = Restaurant.find(params[:restaurant_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to restaurants_path, alert: "Restaurant not found."
  end

  def set_compliance_report
    @compliance_report = @restaurant.compliance_reports.find(params[:id])
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
end

