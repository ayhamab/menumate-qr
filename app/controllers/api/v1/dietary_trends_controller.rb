class Api::V1::DietaryTrendsController < ApplicationController
  before_action :authenticate_api_key
  skip_before_action :verify_authenticity_token

  # GET /api/v1/dietary_trends
  def index
    start_date = params[:start_date] ? Date.parse(params[:start_date]) : 30.days.ago
    end_date = params[:end_date] ? Date.parse(params[:end_date]) : Date.today
    region = params[:region]
    tag = params[:dietary_tag]

    trends = DietaryTrend.by_date_range(start_date, end_date)
    trends = trends.by_region(region) if region.present?
    trends = trends.by_tag(tag) if tag.present?

    @brand_analytic.record_api_call unless @brand_analytic.nil?

    render json: {
      data: trends.map { |t| trend_to_json(t) },
      meta: {
        total: trends.count,
        start_date: start_date,
        end_date: end_date,
        region: region,
        dietary_tag: tag
      }
    }
  end

  # GET /api/v1/dietary_trends/:id
  def show
    trend = DietaryTrend.find(params[:id])
    @brand_analytic.record_api_call unless @brand_analytic.nil?

    render json: {
      data: trend_to_json(trend)
    }
  end

  # GET /api/v1/dietary_trends/summary
  def summary
    start_date = params[:start_date] ? Date.parse(params[:start_date]) : 30.days.ago
    end_date = params[:end_date] ? Date.parse(params[:end_date]) : Date.today
    region = params[:region]

    # Get top trends
    top_trends = DietaryTrend.top_trends(limit: 10, start_date: start_date, end_date: end_date)
    growth_leaders = DietaryTrend.growth_leaders(limit: 10, start_date: start_date, end_date: end_date)

    @brand_analytic.record_api_call unless @brand_analytic.nil?

    render json: {
      data: {
        top_trends: top_trends.map { |t| trend_to_json(t) },
        growth_leaders: growth_leaders.map { |t| trend_to_json(t) },
        period: {
          start_date: start_date,
          end_date: end_date,
          region: region
        }
      }
    }
  end

  # GET /api/v1/dietary_trends/export
  def export
    start_date = params[:start_date] ? Date.parse(params[:start_date]) : 30.days.ago
    end_date = params[:end_date] ? Date.parse(params[:end_date]) : Date.today
    region = params[:region]
    format = params[:format] || 'json'

    trends = DietaryTrend.by_date_range(start_date, end_date)
    trends = trends.by_region(region) if region.present?

    @brand_analytic.record_api_call unless @brand_analytic.nil?

    case format.downcase
    when 'csv'
      send_data trends_to_csv(trends), 
                filename: "dietary_trends_#{start_date}_#{end_date}.csv",
                type: 'text/csv'
    when 'json'
      render json: {
        data: trends.map { |t| trend_to_json(t) },
        meta: {
          exported_at: Time.current.iso8601,
          total_records: trends.count,
          period: { start_date: start_date, end_date: end_date, region: region }
        }
      }
    else
      render json: { error: 'Invalid format. Use csv or json' }, status: :bad_request
    end
  end

  private

  def authenticate_api_key
    api_key = request.headers['X-API-Key'] || params[:api_key]
    
    unless api_key.present?
      render json: { error: 'API key required' }, status: :unauthorized
      return
    end

    @brand_analytic = BrandAnalytic.active.find_by(api_key: api_key)
    
    unless @brand_analytic
      render json: { error: 'Invalid API key' }, status: :unauthorized
      return
    end

    unless @brand_analytic.within_api_limits?
      render json: { error: 'API rate limit exceeded' }, status: :too_many_requests
      return
    end
  end

  def trend_to_json(trend)
    {
      id: trend.id,
      dietary_tag: trend.dietary_tag,
      trend_percentage: trend.trend_percentage.to_f,
      sample_size: trend.sample_size,
      growth_rate: trend.growth_rate&.to_f,
      region: trend.region,
      category: trend.category,
      trend_date: trend.trend_date.iso8601,
      metadata: trend.metadata,
      created_at: trend.created_at.iso8601
    }
  end

  def trends_to_csv(trends)
    require 'csv'
    CSV.generate(headers: true) do |csv|
      csv << ['Dietary Tag', 'Trend Percentage', 'Sample Size', 'Growth Rate', 'Region', 'Category', 'Trend Date']
      trends.each do |trend|
        csv << [
          trend.dietary_tag,
          trend.trend_percentage,
          trend.sample_size,
          trend.growth_rate,
          trend.region,
          trend.category,
          trend.trend_date
        ]
      end
    end
  end
end
