class ComplianceReport < ApplicationRecord
  belongs_to :restaurant
  belongs_to :region, optional: true

  # Report types: full_compliance, regional_compliance, law_specific, menu_item_audit
  validates :report_type, inclusion: {
    in: %w[full_compliance regional_compliance law_specific menu_item_audit]
  }

  # Serialize findings and recommendations as JSON
  serialize :findings, coder: JSON
  serialize :recommendations, coder: JSON
  serialize :violations_summary, coder: JSON

  # Scopes
  scope :by_type, ->(type) { where(report_type: type) if type.present? }
  scope :by_region, ->(region) { where(region: region) if region.present? }
  scope :recent, -> { order(created_at: :desc) }

  # Instance methods
  def full_compliance?
    report_type == 'full_compliance'
  end

  def regional_compliance?
    report_type == 'regional_compliance'
  end

  def has_findings?
    findings.present? && findings.any?
  end

  def has_recommendations?
    recommendations.present? && recommendations.any?
  end

  def violation_count
    violations_summary&.sum { |v| v['count'] } || 0
  end
end

