class DietaryTrend < ApplicationRecord
  serialize :metadata, coder: JSON

  # Validations
  validates :dietary_tag, :trend_percentage, :sample_size, :trend_date, presence: true
  validates :trend_percentage, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }
  validates :sample_size, numericality: { greater_than: 0 }

  # Scopes
  scope :recent, -> { order(trend_date: :desc) }
  scope :by_tag, ->(tag) { where(dietary_tag: tag) }
  scope :by_region, ->(region) { where(region: region) if region.present? }
  scope :by_date_range, ->(start_date, end_date) { where(trend_date: start_date..end_date) }
  scope :growing, -> { where('growth_rate > 0') }
  scope :declining, -> { where('growth_rate < 0') }

  # Class methods
  def self.aggregate_trends(start_date: 30.days.ago, end_date: Date.today, region: nil)
    # Aggregate dietary trends from menu items
    menu_items = MenuItem.joins(:restaurant)
    menu_items = menu_items.where('restaurants.address LIKE ?', "%#{region}%") if region.present?
    
    total_items = menu_items.count
    return [] if total_items.zero?

    trends = []
    dietary_tags = MenuItem.all.pluck(:dietary_tags).flatten.compact.uniq

    dietary_tags.each do |tag|
      items_with_tag = menu_items.where("JSON_EXTRACT(dietary_tags, '$') LIKE ?", "%#{tag}%")
      count = items_with_tag.count
      percentage = (count.to_f / total_items * 100).round(2)

      # Calculate growth rate (compare to previous period)
      previous_period = by_tag(tag).by_date_range(start_date - (end_date - start_date), start_date).last
      growth_rate = if previous_period
        ((percentage - previous_period.trend_percentage) / previous_period.trend_percentage * 100).round(2)
      else
        0
      end

      trends << {
        dietary_tag: tag,
        trend_percentage: percentage,
        sample_size: total_items,
        growth_rate: growth_rate,
        count: count
      }
    end

    trends.sort_by { |t| -t[:trend_percentage] }
  end

  def self.generate_trend_report(start_date: 30.days.ago, end_date: Date.today, region: nil)
    trends = aggregate_trends(start_date: start_date, end_date: end_date, region: region)
    
    # Save trends to database (avoid duplicates)
    trends.each do |trend_data|
      existing = find_by(
        dietary_tag: trend_data[:dietary_tag],
        region: region,
        trend_date: end_date
      )

      if existing
        existing.update(
          trend_percentage: trend_data[:trend_percentage],
          sample_size: trend_data[:sample_size],
          growth_rate: trend_data[:growth_rate],
          metadata: {
            item_count: trend_data[:count],
            total_items: trend_data[:sample_size]
          }
        )
      else
        create!(
          dietary_tag: trend_data[:dietary_tag],
          region: region,
          trend_percentage: trend_data[:trend_percentage],
          sample_size: trend_data[:sample_size],
          trend_date: end_date,
          growth_rate: trend_data[:growth_rate],
          metadata: {
            item_count: trend_data[:count],
            total_items: trend_data[:sample_size]
          }
        )
      end
    end

    trends
  end

  def self.top_trends(limit: 10, start_date: 30.days.ago, end_date: Date.today)
    by_date_range(start_date, end_date)
      .order(trend_percentage: :desc)
      .limit(limit)
  end

  def self.growth_leaders(limit: 10, start_date: 30.days.ago, end_date: Date.today)
    by_date_range(start_date, end_date)
      .where('growth_rate > 0')
      .order(growth_rate: :desc)
      .limit(limit)
  end
end
