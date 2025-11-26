class BrandAnalytic < ApplicationRecord
  # Validations
  validates :brand_name, :email, :api_key, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :subscription_tier, inclusion: { in: %w[basic premium enterprise] }
  validates :api_key, uniqueness: true

  # Callbacks
  before_validation :generate_api_key, on: :create

  # Scopes
  scope :active, -> { where(active: true) }
  scope :by_tier, ->(tier) { where(subscription_tier: tier) }

  # Class methods
  def self.subscription_tiers
    {
      'basic' => {
        name: 'Basic',
        price: 299.00,
        features: [
          'Monthly trend reports',
          'Basic dietary tag analytics',
          'Email support',
          'CSV data export'
        ],
        limits: {
          api_calls_per_month: 1000,
          data_retention_days: 90
        }
      },
      'premium' => {
        name: 'Premium',
        price: 999.00,
        features: [
          'Weekly trend reports',
          'Advanced analytics dashboard',
          'Regional breakdowns',
          'API access',
          'Priority support',
          'JSON/CSV data export',
          'Custom date ranges'
        ],
        limits: {
          api_calls_per_month: 10000,
          data_retention_days: 365
        }
      },
      'enterprise' => {
        name: 'Enterprise',
        price: 2999.00,
        features: [
          'Real-time analytics',
          'Full API access',
          'Custom reports',
          'Dedicated account manager',
          'White-label reports',
          'Unlimited data export',
          'Historical data access'
        ],
        limits: {
          api_calls_per_month: Float::INFINITY,
          data_retention_days: Float::INFINITY
        }
      }
    }
  end

  # Instance methods
  def subscription_details
    self.class.subscription_tiers[subscription_tier] || self.class.subscription_tiers['basic']
  end

  def can_access_feature?(feature)
    case feature
    when :api_access
      subscription_tier != 'basic'
    when :real_time_data
      subscription_tier == 'enterprise'
    when :custom_reports
      subscription_tier == 'enterprise'
    else
      true
    end
  end

  def within_api_limits?
    return true if subscription_tier == 'enterprise'
    limit = subscription_details[:limits][:api_calls_per_month]
    return true if limit == Float::INFINITY
    api_calls_count < limit
  end

  def record_api_call
    increment!(:api_calls_count)
    touch(:last_access_at)
  end

  private

  def generate_api_key
    self.api_key ||= SecureRandom.hex(32)
  end
end
