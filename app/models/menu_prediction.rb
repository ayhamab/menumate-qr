class MenuPrediction < ApplicationRecord
  belongs_to :menu_item
  belongs_to :restaurant
  belongs_to :demographic_data, optional: true

  # Prediction types: success_score, popularity_score, revenue_potential, dietary_fit
  validates :prediction_type, inclusion: {
    in: %w[success_score popularity_score revenue_potential dietary_fit]
  }

  # Serialize features and predictions as JSON
  serialize :features, coder: JSON
  serialize :prediction_details, coder: JSON

  # Scopes
  scope :recent, -> { order(created_at: :desc) }
  scope :by_type, ->(type) { where(prediction_type: type) if type.present? }
  scope :high_confidence, -> { where('confidence_score >= ?', 0.7) }
  scope :by_restaurant, ->(restaurant) { where(restaurant: restaurant) if restaurant.present? }

  # Instance methods
  def success_score?
    prediction_type == 'success_score'
  end

  def popularity_score?
    prediction_type == 'popularity_score'
  end

  def revenue_potential?
    prediction_type == 'revenue_potential'
  end

  def high_confidence?
    confidence_score.present? && confidence_score >= 0.7
  end

  def medium_confidence?
    confidence_score.present? && confidence_score >= 0.5 && confidence_score < 0.7
  end

  def low_confidence?
    confidence_score.present? && confidence_score < 0.5
  end

  def prediction_display
    case prediction_type
    when 'success_score'
      "#{(predicted_value * 100).round(1)}% success probability"
    when 'popularity_score'
      "#{(predicted_value * 10).round(1)}/10 popularity"
    when 'revenue_potential'
      "$#{predicted_value.round(2)} estimated monthly revenue"
    when 'dietary_fit'
      "#{(predicted_value * 100).round(1)}% demographic fit"
    else
      predicted_value.to_s
    end
  end

  def recommendation
    return nil unless prediction_details.present?
    prediction_details['recommendation']
  end

  def risk_factors
    return [] unless prediction_details.present?
    prediction_details['risk_factors'] || []
  end
end

