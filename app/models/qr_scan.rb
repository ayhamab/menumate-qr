class QrScan < ApplicationRecord
  belongs_to :restaurant

  validates :scanned_at, presence: true

  scope :recent, -> { where('scanned_at >= ?', 30.days.ago) }
  scope :today, -> { where('scanned_at >= ?', Date.today.beginning_of_day) }
  scope :this_week, -> { where('scanned_at >= ?', Date.today.beginning_of_week) }
  scope :this_month, -> { where('scanned_at >= ?', Date.today.beginning_of_month) }
end

