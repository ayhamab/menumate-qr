class ConsultantReport < ApplicationRecord
  belongs_to :consultant
  belongs_to :restaurant

  # Report types: menu_analysis, performance_review, dietary_compliance, pricing_analysis, recommendations
  validates :report_type, inclusion: {
    in: %w[menu_analysis performance_review dietary_compliance pricing_analysis recommendations]
  }
  validates :title, presence: true, length: { maximum: 255 }
  validates :content, presence: true

  # Serialize findings and recommendations as JSON
  serialize :findings, coder: JSON
  serialize :recommendations, coder: JSON

  # Scopes
  scope :by_type, ->(type) { where(report_type: type) if type.present? }
  scope :by_restaurant, ->(restaurant) { where(restaurant: restaurant) if restaurant.present? }
  scope :recent, -> { order(created_at: :desc) }

  # Instance methods
  def menu_analysis?
    report_type == 'menu_analysis'
  end

  def performance_review?
    report_type == 'performance_review'
  end

  def has_findings?
    findings.present? && findings.any?
  end

  def has_recommendations?
    recommendations.present? && recommendations.any?
  end
end

