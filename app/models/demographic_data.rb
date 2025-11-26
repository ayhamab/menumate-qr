class DemographicData < ApplicationRecord
  belongs_to :restaurant, optional: true
  belongs_to :location, optional: true

  # Serialize demographic metrics as JSON
  serialize :age_distribution, coder: JSON
  serialize :income_distribution, coder: JSON
  serialize :cultural_preferences, coder: JSON
  serialize :dietary_preferences, coder: JSON
  serialize :dining_preferences, coder: JSON

  # Validations
  validates :region_code, presence: true, length: { maximum: 50 }
  validates :data_source, inclusion: {
    in: %w[census_api manual_entry third_party_api estimated]
  }

  # Scopes
  scope :by_region, ->(code) { where(region_code: code) if code.present? }
  scope :recent, -> { order(updated_at: :desc) }
  scope :verified, -> { where(verified: true) }

  # Instance methods
  def verified?
    verified == true
  end

  def average_age
    return nil unless age_distribution.present?
    
    total = 0
    count = 0
    age_distribution.each do |range, percentage|
      # Parse range like "25-34" or "65+"
      if range.include?('-')
        min, max = range.split('-').map(&:to_i)
        avg = (min + max) / 2.0
      elsif range.include?('+')
        min = range.gsub('+', '').to_i
        avg = min + 10 # Estimate for open-ended ranges
      else
        avg = range.to_i
      end
      total += avg * (percentage / 100.0)
      count += percentage / 100.0
    end
    count > 0 ? (total / count).round(1) : nil
  end

  def median_income
    return nil unless income_distribution.present?
    
    # Calculate median from distribution
    sorted = income_distribution.sort_by { |range, _| range_to_number(range) }
    cumulative = 0
    sorted.each do |range, percentage|
      cumulative += percentage
      return range_to_number(range) if cumulative >= 50
    end
    nil
  end

  def primary_cultural_group
    return nil unless cultural_preferences.present?
    cultural_preferences.max_by { |_, percentage| percentage }&.first
  end

  def top_dietary_preferences
    return [] unless dietary_preferences.present?
    dietary_preferences.sort_by { |_, percentage| -percentage }
                       .first(3)
                       .map { |pref, _| pref }
  end

  def demographic_score
    # Calculate a composite demographic score for ML features
    score = 0.0
    
    # Age factor (younger demographics may prefer different items)
    avg_age = average_age
    score += (100 - avg_age) * 0.1 if avg_age
    
    # Income factor (higher income may prefer premium items)
    med_income = median_income
    score += (med_income / 1000.0) * 0.1 if med_income
    
    # Cultural diversity factor
    if cultural_preferences.present?
      values = cultural_preferences.values.map(&:to_f)
      mean = values.sum / values.count
      variance = values.sum { |v| (v - mean) ** 2 } / values.count
      diversity = Math.sqrt(variance) rescue 0
      score += diversity * 0.2
    end
    
    score.round(2)
  end

  private

  def range_to_number(range_str)
    # Convert income range like "$50,000-$75,000" to number
    numbers = range_str.scan(/\d+/).map(&:to_i)
    numbers.any? ? numbers.sum / numbers.count : 0
  end
end

