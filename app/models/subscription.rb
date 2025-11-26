class Subscription < ApplicationRecord
  belongs_to :restaurant

  # Validations
  validates :plan_name, presence: true, inclusion: { in: %w[basic pro enterprise] }
  validates :status, presence: true, inclusion: { 
    in: %w[incomplete incomplete_expired trialing active past_due canceled unpaid paused]
  }
  validates :stripe_subscription_id, uniqueness: true, allow_nil: true

  # Scopes
  scope :active, -> { where(status: 'active') }
  scope :trialing, -> { where(status: 'trialing') }
  scope :active_or_trialing, -> { where(status: ['active', 'trialing']) }
  scope :canceled, -> { where(status: 'canceled') }

  # Class methods
  def self.plans
    {
      'basic' => {
        name: 'Basic',
        price: 9.99,
        price_id: ENV['STRIPE_BASIC_PRICE_ID'],
        features: [
          'Up to 50 menu items',
          'Basic analytics',
          'QR code generation',
          'Email support',
          '1 restaurant location'
        ],
        limits: {
          menu_items: 50,
          locations: 1,
          promotions: 5,
          languages: 2
        }
      },
      'pro' => {
        name: 'Pro',
        price: 29.99,
        price_id: ENV['STRIPE_PRO_PRICE_ID'],
        features: [
          'Unlimited menu items',
          'Advanced analytics',
          'QR code generation',
          'Priority support',
          'Multiple restaurant locations',
          'Unlimited promotions',
          'Multi-language support',
          'Custom branding'
        ],
        limits: {
          menu_items: Float::INFINITY,
          locations: 5,
          promotions: Float::INFINITY,
          languages: Float::INFINITY
        }
      },
      'enterprise' => {
        name: 'Enterprise',
        price: 99.99,
        price_id: ENV['STRIPE_ENTERPRISE_PRICE_ID'],
        features: [
          'Everything in Pro',
          'Unlimited locations',
          'API access',
          'Dedicated account manager',
          'Custom integrations',
          'White-label solution',
          'Advanced security features',
          'SLA guarantee'
        ],
        limits: {
          menu_items: Float::INFINITY,
          locations: Float::INFINITY,
          promotions: Float::INFINITY,
          languages: Float::INFINITY
        }
      }
    }
  end

  # Instance methods
  def active?
    status == 'active' || status == 'trialing'
  end

  def canceled?
    status == 'canceled'
  end

  def past_due?
    status == 'past_due'
  end

  def plan_details
    self.class.plans[plan_name] || self.class.plans['basic']
  end

  def plan_price
    plan_details[:price]
  end

  def plan_features
    plan_details[:features] || []
  end

  def plan_limits
    plan_details[:limits] || {}
  end

  def within_limits?(resource_type, count)
    limit = plan_limits[resource_type.to_sym]
    return true if limit.nil?
    return true if limit == Float::INFINITY
    count <= limit
  end

  def can_access_feature?(feature)
    case feature
    when :advanced_analytics
      plan_name != 'basic'
    when :multiple_locations
      plan_name != 'basic'
    when :unlimited_promotions
      plan_name != 'basic'
    when :api_access
      plan_name == 'enterprise'
    when :white_label
      plan_name == 'enterprise'
    else
      true
    end
  end
end
