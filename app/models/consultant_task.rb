class ConsultantTask < ApplicationRecord
  belongs_to :consultant
  belongs_to :restaurant, optional: true
  belongs_to :menu_item, optional: true

  # Task types: menu_review, pricing_analysis, dietary_compliance, menu_optimization, training, other
  validates :task_type, inclusion: {
    in: %w[menu_review pricing_analysis dietary_compliance menu_optimization training other]
  }
  validates :title, presence: true, length: { maximum: 255 }
  validates :status, inclusion: { in: %w[pending in_progress completed cancelled] }
  validates :priority, inclusion: { in: %w[low medium high urgent] }

  # Scopes
  scope :pending, -> { where(status: 'pending') }
  scope :in_progress, -> { where(status: 'in_progress') }
  scope :completed, -> { where(status: 'completed') }
  scope :by_restaurant, ->(restaurant) { where(restaurant: restaurant) if restaurant.present? }
  scope :by_priority, ->(priority) { where(priority: priority) if priority.present? }
  scope :urgent, -> { where(priority: 'urgent') }
  scope :due_soon, -> { where('due_date <= ? AND due_date >= ?', 7.days.from_now, Date.current) }
  scope :overdue, -> { where('due_date < ?', Date.current).where.not(status: ['completed', 'cancelled']) }

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

  def overdue?
    due_date.present? && due_date < Date.current && !completed? && !cancelled?
  end

  def due_soon?
    due_date.present? && due_date <= 7.days.from_now && due_date >= Date.current
  end

  def cancelled?
    status == 'cancelled'
  end

  def urgent?
    priority == 'urgent'
  end
end

