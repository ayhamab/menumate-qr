class SeasonalMenuSchedule < ApplicationRecord
  belongs_to :restaurant
  belongs_to :menu_item

  # Validations
  validates :name, presence: true, length: { maximum: 100 }
  validates :start_date, presence: true
  validates :end_date, presence: true
  validate :end_date_after_start_date
  validate :time_range_valid

  # Scopes
  scope :active, -> { where(active: true) }
  scope :current, -> { where('start_date <= ? AND end_date >= ?', Date.today, Date.today) }
  scope :upcoming, -> { where('start_date > ?', Date.today) }
  scope :past, -> { where('end_date < ?', Date.today) }
  scope :recurring, -> { where(recurring: true) }

  # Class methods
  def self.current_for_menu_item(menu_item)
    now = Time.current
    schedules = active.current.where(menu_item: menu_item).to_a
    schedules.find { |schedule| schedule.active_at_time?(now) }
  end

  def self.should_be_visible?(menu_item)
    # Check if menu item has any active seasonal schedule
    schedule = current_for_menu_item(menu_item)
    return true unless schedule # No schedule means always visible
    
    # If there's a schedule, check if it's active
    schedule.active_at_time?(Time.current)
  end

  # Instance methods
  def active_at_time?(time = Time.current)
    return false unless active?
    
    date = time.to_date
    time_of_day = time.strftime('%H:%M:%S')
    
    # Check if date is within range
    return false if date < start_date || date > end_date
    
    # If recurring, check if it matches the pattern
    if recurring?
      return matches_recurring_pattern?(date)
    end
    
    # Check time range if specified
    if start_time.present? && end_time.present?
      return time_of_day >= start_time.strftime('%H:%M:%S') && 
             time_of_day <= end_time.strftime('%H:%M:%S')
    end
    
    true
  end

  def matches_recurring_pattern?(date)
    return false unless recurring_pattern.present?
    
    case recurring_pattern
    when 'yearly'
      # Same month and day each year
      date.month == start_date.month && date.day == start_date.day
    when 'monthly'
      # Same day of month each month
      date.day == start_date.day
    when 'weekly'
      # Same day of week
      date.wday == start_date.wday
    when 'daily'
      # Every day within date range
      true
    else
      false
    end
  end

  def status
    now = Date.today
    if end_date < now
      'past'
    elsif start_date > now
      'upcoming'
    else
      'active'
    end
  end

  def display_name
    "#{name} (#{start_date.strftime('%b %d')} - #{end_date.strftime('%b %d, %Y')})"
  end

  private

  def end_date_after_start_date
    return unless start_date.present? && end_date.present?
    
    if end_date < start_date
      errors.add(:end_date, "must be after start date")
    end
  end

  def time_range_valid
    return unless start_time.present? && end_time.present?
    
    if start_time >= end_time
      errors.add(:end_time, "must be after start time")
    end
  end
end
