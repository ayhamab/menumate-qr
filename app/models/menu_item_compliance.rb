class MenuItemCompliance < ApplicationRecord
  belongs_to :menu_item
  belongs_to :dietary_law
  belongs_to :region, optional: true

  # Compliance status: compliant, non_compliant, pending_review, exempt
  validates :status, inclusion: {
    in: %w[compliant non_compliant pending_review exempt]
  }

  # Serialize violations and notes as JSON
  serialize :violations, coder: JSON
  serialize :notes, coder: JSON

  # Scopes
  scope :compliant, -> { where(status: 'compliant') }
  scope :non_compliant, -> { where(status: 'non_compliant') }
  scope :pending_review, -> { where(status: 'pending_review') }
  scope :by_region, ->(region) { where(region: region) if region.present? }
  scope :by_law, ->(law) { where(dietary_law: law) if law.present? }
  scope :recent, -> { order(updated_at: :desc) }

  # Instance methods
  def compliant?
    status == 'compliant'
  end

  def non_compliant?
    status == 'non_compliant'
  end

  def pending_review?
    status == 'pending_review'
  end

  def exempt?
    status == 'exempt'
  end

  def has_violations?
    violations.present? && violations.any?
  end

  def violation_count
    violations&.count || 0
  end

  def last_checked_recently?
    return false unless last_checked_at.present?
    last_checked_at > 30.days.ago
  end

  # Auto-check compliance
  def check_compliance!
    result = dietary_law.check_compliance(menu_item)
    
    update(
      status: result[:compliant] ? 'compliant' : 'non_compliant',
      violations: result[:violations],
      last_checked_at: Time.current,
      checked_by: 'system'
    )
  end
end

