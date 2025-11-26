class Restaurant < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :corporate_account, optional: true
  has_many :locations, dependent: :destroy
  has_many :menu_items, dependent: :destroy
  has_many :qr_codes, dependent: :destroy
  has_many :qr_scans, dependent: :destroy
  has_many :promotions, dependent: :destroy
  has_one :subscription, dependent: :destroy
  has_one :branding, dependent: :destroy
  has_many :seasonal_menu_schedules, dependent: :destroy
  has_many :brands, dependent: :destroy
  has_many :restaurant_teams, dependent: :destroy
  has_many :team_members, through: :restaurant_teams, source: :user
  has_many :activity_logs, dependent: :destroy
  has_many :split_tests, dependent: :destroy
  has_many :recipes, dependent: :destroy
  has_many :menu_item_analytics, dependent: :destroy
  has_many :training_modules, dependent: :destroy
  has_many :training_sessions, dependent: :destroy
  has_many :training_completions, dependent: :destroy
  has_many :supplier_contacts, dependent: :destroy
  has_many :supplier_reviews, dependent: :destroy
  has_many :supplier_promotion_targets, dependent: :destroy
  has_many :targeted_promotions, through: :supplier_promotion_targets, source: :supplier_promotion
  has_many :consultant_clients, dependent: :destroy
  has_many :consultants, through: :consultant_clients
  has_many :consultant_notes, dependent: :destroy
  has_many :consultant_tasks, dependent: :destroy
  has_many :consultant_reports, dependent: :destroy
  has_many :restaurant_regions, dependent: :destroy
  has_many :regions, through: :restaurant_regions
  has_many :compliance_reports, dependent: :destroy
  has_many :demographic_data, dependent: :destroy
  has_many :menu_predictions, dependent: :destroy
  has_many :dietary_feedbacks, dependent: :destroy

  # Validations
  # Note: user is optional to allow restaurants without authentication
  validates :name, presence: { message: "can't be blank" }, 
                   length: { minimum: 2, maximum: 100, message: "must be between 2 and 100 characters" }
  validates :address, presence: { message: "can't be blank" },
                      length: { minimum: 5, maximum: 255, message: "must be between 5 and 255 characters" }
  validates :description, length: { maximum: 1000, message: "must be less than 1000 characters" }, 
                          allow_blank: true
  validates :phone_number, format: { 
                            with: /\A[\d\s\(\)\-\+\.]+\z/, 
                            message: "contains invalid characters" 
                          }, 
                          length: { maximum: 20, message: "must be less than 20 characters" },
                          allow_blank: true
  validates :cuisine, length: { maximum: 50, message: "must be less than 50 characters" },
                      allow_blank: true

  # Subscription methods
  def subscription_active?
    subscription&.active? || false
  end

  def subscription_plan
    subscription&.plan_name || 'basic'
  end

  def subscription_status
    subscription&.status || 'incomplete'
  end

  def can_access_feature?(feature)
    return true unless subscription # Allow access if no subscription (grace period)
    subscription.can_access_feature?(feature)
  end

  def within_limits?(resource_type, count)
    return true unless subscription # Allow if no subscription (grace period)
    subscription.within_limits?(resource_type, count)
  end

  # Branding methods
  def has_branding?
    branding.present? && branding.has_custom_branding?
  end

  def can_use_white_label?
    can_access_feature?(:white_label)
  end

  def branding_or_default
    branding || Branding.new(restaurant: self)
  end

  # Scopes for discovery/search
  scope :by_cuisine, ->(cuisine) { where("LOWER(cuisine) LIKE ?", "%#{cuisine.downcase}%") if cuisine.present? }
  scope :by_name, ->(name) { where("LOWER(name) LIKE ?", "%#{name.downcase}%") if name.present? }
  scope :with_dietary_option, ->(dietary_tag) {
    if dietary_tag.present?
      # Search for the dietary tag in the JSON array
      # SQLite stores JSON as text, so we search for the tag in the JSON string
      joins(:menu_items)
        .where("menu_items.dietary_tags LIKE ?", "%\"#{dietary_tag}\"%")
        .distinct
    else
      all
    end
  }
end

