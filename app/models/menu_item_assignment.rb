class MenuItemAssignment < ApplicationRecord
  belongs_to :menu_item
  belongs_to :assigned_to, class_name: 'User', foreign_key: 'assigned_to_id'
  belongs_to :assigned_by, class_name: 'User', foreign_key: 'assigned_by_id', optional: true

  # Status: pending, in_progress, completed, reviewed
  validates :status, inclusion: { in: %w[pending in_progress completed reviewed] }
  validates :priority, inclusion: { in: %w[low medium high urgent] }, allow_nil: true

  # Scopes
  scope :pending, -> { where(status: 'pending') }
  scope :in_progress, -> { where(status: 'in_progress') }
  scope :completed, -> { where(status: 'completed') }
  scope :active, -> { where(status: ['pending', 'in_progress']) }
  scope :by_priority, ->(priority) { where(priority: priority) if priority.present? }

  # Instance methods
  def pending?
    status == 'pending'
  end

  def in_progress?
    status == 'in_progress'
  end

  def completed?
    status == 'completed'
  end

  def reviewed?
    status == 'reviewed'
  end

  def mark_in_progress!
    update(status: 'in_progress', started_at: Time.current)
  end

  def mark_completed!
    update(status: 'completed', completed_at: Time.current)
  end

  def mark_reviewed!
    update(status: 'reviewed', reviewed_at: Time.current)
  end
end

