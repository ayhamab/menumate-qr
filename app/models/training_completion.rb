class TrainingCompletion < ApplicationRecord
  belongs_to :training_module
  belongs_to :user
  belongs_to :restaurant, optional: true
  belongs_to :training_session

  # Scopes
  scope :passed, -> { joins(:training_session).where(training_sessions: { status: 'passed' }) }
  scope :by_user, ->(user) { where(user: user) if user.present? }
  scope :by_restaurant, ->(restaurant) { where(restaurant: restaurant) if restaurant.present? }
  scope :recent, -> { order(completed_at: :desc) }

  # Instance methods
  def passed?
    training_session.passed?
  end

  def certification_valid?
    return true unless training_module.certification_valid_days.present?
    return false unless completed_at.present?
    
    (Date.current - completed_at.to_date).to_i <= training_module.certification_valid_days
  end

  def days_until_expiry
    return nil unless training_module.certification_valid_days.present? && completed_at.present?
    expiry_date = completed_at.to_date + training_module.certification_valid_days.days
    (expiry_date - Date.current).to_i
  end
end

