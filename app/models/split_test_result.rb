class SplitTestResult < ApplicationRecord
  belongs_to :split_test
  belongs_to :split_test_variant

  # Event types: impression, click, order
  validates :event_type, inclusion: { in: %w[impression click order] }
  validates :session_id, presence: true

  # Scopes
  scope :impressions, -> { where(event_type: 'impression') }
  scope :clicks, -> { where(event_type: 'click') }
  scope :orders, -> { where(event_type: 'order') }
  scope :by_date, ->(date) { where(created_at: date.beginning_of_day..date.end_of_day) }
  scope :recent, -> { order(created_at: :desc) }

  # Track impression
  def self.track_impression(split_test, variant, session_id, request = nil)
    create(
      split_test: split_test,
      split_test_variant: variant,
      event_type: 'impression',
      session_id: session_id,
      ip_address: request&.remote_ip,
      user_agent: request&.user_agent
    )
  end

  # Track click
  def self.track_click(split_test, variant, session_id, request = nil)
    create(
      split_test: split_test,
      split_test_variant: variant,
      event_type: 'click',
      session_id: session_id,
      ip_address: request&.remote_ip,
      user_agent: request&.user_agent
    )
  end

  # Track order
  def self.track_order(split_test, variant, session_id, request = nil, revenue: nil)
    create(
      split_test: split_test,
      split_test_variant: variant,
      event_type: 'order',
      session_id: session_id,
      ip_address: request&.remote_ip,
      user_agent: request&.user_agent,
      revenue: revenue
    )
  end
end

