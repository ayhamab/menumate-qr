class CorporateAccount < ApplicationRecord
  has_many :corporate_account_users, dependent: :destroy
  has_many :users, through: :corporate_account_users
  has_many :restaurants, dependent: :nullify
  has_many :menu_templates, dependent: :destroy
  has_many :menu_consistency_reports, dependent: :destroy

  # Validations
  validates :name, presence: true, length: { maximum: 100 }
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :subscription_tier, inclusion: { in: %w[basic premium enterprise] }

  # Scopes
  scope :active, -> { where(active: true) }

  # Class methods
  def self.subscription_tiers
    {
      'basic' => {
        name: 'Basic Corporate',
        price: 499.00,
        max_restaurants: 5,
        max_locations_per_restaurant: 10,
        features: [
          'Up to 5 restaurants',
          'Up to 10 locations per restaurant',
          'Centralized menu management',
          'Basic analytics',
          'Email support'
        ]
      },
      'premium' => {
        name: 'Premium Corporate',
        price: 1499.00,
        max_restaurants: 25,
        max_locations_per_restaurant: 50,
        features: [
          'Up to 25 restaurants',
          'Up to 50 locations per restaurant',
          'Centralized menu management',
          'Advanced analytics',
          'Location-specific menus',
          'Priority support',
          'Custom branding'
        ]
      },
      'enterprise' => {
        name: 'Enterprise Corporate',
        price: 4999.00,
        max_restaurants: Float::INFINITY,
        max_locations_per_restaurant: Float::INFINITY,
        features: [
          'Unlimited restaurants',
          'Unlimited locations',
          'Centralized menu management',
          'Advanced analytics',
          'Location-specific menus',
          'White-label branding',
          'Dedicated account manager',
          'API access',
          'Custom integrations'
        ]
      }
    }
  end

  # Instance methods
  def subscription_details
    self.class.subscription_tiers[subscription_tier] || self.class.subscription_tiers['basic']
  end

  def can_add_restaurant?
    return true if max_restaurants == Float::INFINITY
    restaurants.count < max_restaurants
  end

  def can_add_location?(restaurant)
    return true if max_locations_per_restaurant == Float::INFINITY
    restaurant.locations.count < max_locations_per_restaurant
  end

  def total_locations
    restaurants.sum { |r| r.locations.count }
  end

  def total_menu_items
    restaurants.sum { |r| r.menu_items.count }
  end

  def admin_users
    corporate_account_users.where(role: 'admin').includes(:user).map(&:user)
  end

  def manager_users
    corporate_account_users.where(role: ['admin', 'manager']).includes(:user).map(&:user)
  end

  def has_user?(user)
    corporate_account_users.active.exists?(user: user)
  end

  def user_role(user)
    corporate_account_users.active.find_by(user: user)&.role
  end

  def can_manage?(user)
    role = user_role(user)
    role == 'admin' || role == 'manager'
  end
end
