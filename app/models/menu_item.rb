class MenuItem < ApplicationRecord
  belongs_to :restaurant
  belongs_to :location, optional: true # Location-specific menu items
  belongs_to :brand, optional: true # Brand-specific menu items (for virtual restaurants)
  has_one_attached :image
  has_one_attached :model_3d # 3D model for AR (GLB, GLTF format)
  has_many :menu_item_promotions, dependent: :destroy
  has_many :promotions, through: :menu_item_promotions
  has_many :ratings, dependent: :destroy
  has_many :dietary_accuracy_reports, dependent: :destroy
  has_many :seasonal_menu_schedules, dependent: :destroy
  has_many :menu_item_ingredients, dependent: :destroy
  has_many :ingredients, through: :menu_item_ingredients
  has_many :menu_item_assignments, dependent: :destroy
  has_many :assigned_users, through: :menu_item_assignments, source: :assigned_to
  has_many :menu_item_comments, dependent: :destroy
  has_many :split_tests, dependent: :destroy
  has_one :recipe, dependent: :destroy
  has_many :menu_item_analytics, dependent: :destroy
  has_many :menu_item_compliances, dependent: :destroy
  has_many :dietary_laws, through: :menu_item_compliances
  has_many :menu_predictions, dependent: :destroy
  has_many :dietary_feedbacks, dependent: :destroy

  # Serialize dietary_tags as JSON array
  serialize :dietary_tags, coder: JSON
  # Serialize allergens as JSON array
  serialize :allergens, coder: JSON
  # Serialize translations as JSON
  serialize :name_translations, coder: JSON
  serialize :description_translations, coder: JSON
  # Serialize nutrition_data as JSON
  serialize :nutrition_data, coder: JSON

  # Validations
  validates :name, :price, presence: true
  validates :price, numericality: { greater_than_or_equal_to: 0 }
  validates :category, length: { maximum: 50 }, allow_blank: true

  # Scopes
  scope :by_category, ->(category) { where(category: category) if category.present? }
  scope :ordered, -> { order(:category, :position, :name) }
  scope :with_category, -> { where.not(category: [nil, '']) }
  scope :uncategorized, -> { where(category: [nil, '']) }
  scope :seasonally_available, -> { 
    # Items with no schedules or with active schedules
    left_joins(:seasonal_menu_schedules)
      .where(
        seasonal_menu_schedules: { id: nil }
      )
      .or(
        where(
          seasonal_menu_schedules: { 
            active: true,
            start_date: ..Date.today,
            end_date: Date.today..
          }
        )
      )
      .distinct
  }

  # Callbacks
  before_save :set_default_position, if: :new_record?
  after_initialize :set_default_dietary_tags, if: :new_record?
  after_initialize :set_default_allergens, if: :new_record?
  after_initialize :set_default_translations, if: :new_record?
  
  # Activity logging
  after_create :log_creation
  after_update :log_update
  after_destroy :log_deletion

  # Common allergens
  def self.common_allergens
    {
      'nuts' => 'Tree Nuts',
      'peanuts' => 'Peanuts',
      'shellfish' => 'Shellfish',
      'fish' => 'Fish',
      'eggs' => 'Eggs',
      'milk' => 'Milk/Dairy',
      'soy' => 'Soy',
      'wheat' => 'Wheat/Gluten',
      'sesame' => 'Sesame',
      'sulfites' => 'Sulfites'
    }
  end

  # Check if item has allergens
  def has_allergens?
    allergens.present? && allergens.any?
  end

  # Rating methods
  def average_rating
    Rating.average_rating_for(self)
  end

  def rating_count
    Rating.rating_count_for(self)
  end

  def has_ratings?
    rating_count > 0
  end

  def rating_stars
    (average_rating || 0).round
  end

  # Dietary accuracy
  def unresolved_reports_count
    dietary_accuracy_reports.unresolved.count
  end

  def has_unresolved_reports?
    unresolved_reports_count > 0
  end

  # Instance methods for translations
  def name_in(locale = 'en')
    return name if locale == 'en' || name_translations.blank?
    name_translations[locale.to_s] || name_translations[locale.to_sym] || name
  end

  def description_in(locale = 'en')
    return description if locale == 'en' || description_translations.blank?
    description_translations[locale.to_s] || description_translations[locale.to_sym] || description
  end

  # Supported languages
  def self.supported_languages
    {
      'en' => 'English',
      'es' => 'Español',
      'fr' => 'Français',
      'de' => 'Deutsch',
      'it' => 'Italiano',
      'pt' => 'Português',
      'zh' => '中文',
      'ja' => '日本語',
      'ko' => '한국어',
      'ar' => 'العربية',
      'ru' => 'Русский',
      'nl' => 'Nederlands',
      'pl' => 'Polski',
      'tr' => 'Türkçe'
    }
  end

  # Class methods for categories
  def self.categories
    distinct.pluck(:category).compact.sort
  end

  def self.default_categories
    ['Appetizers', 'Main Courses', 'Desserts', 'Beverages', 'Sides', 'Salads', 'Soups', 'Specials']
  end

  # Nutrition methods
  def has_nutrition_info?
    calories.present? || protein.present? || carbs.present? || fat.present?
  end

  def nutrition_complete?
    calories.present? && protein.present? && carbs.present? && fat.present?
  end

  def nutrition_summary
    return nil unless has_nutrition_info?
    {
      calories: calories,
      protein: protein,
      carbs: carbs,
      fat: fat,
      fiber: fiber,
      sugar: sugar,
      sodium: sodium,
      cholesterol: cholesterol
    }.compact
  end

  # Broadcast changes via Turbo Streams
  after_create_commit :broadcast_create
  after_update_commit :broadcast_update
  after_destroy_commit :broadcast_destroy

  private

  def log_creation
    log_activity('menu_item_created')
  end

  def log_update
    log_activity('menu_item_updated')
  end

  def log_deletion
    log_activity('menu_item_deleted', { item_name: name })
  end

  def log_activity(activity_type, metadata = {})
    return unless restaurant.respond_to?(:activity_logs)
    
    # Note: user will be set by controllers when they perform actions
    restaurant.activity_logs.create(
      user: nil, # Set by controllers
      trackable: self,
      activity_type: activity_type,
      metadata: metadata
    )
  rescue
    # Silently fail if activity logging isn't available
  end

  def set_default_dietary_tags
    self.dietary_tags ||= []
  end

  def set_default_allergens
    self.allergens ||= []
  end

  def set_default_translations
    self.name_translations ||= {}
    self.description_translations ||= {}
  end

  def set_default_position
    if position.nil? || position.zero?
      max_position = restaurant.menu_items.where(category: category).maximum(:position) || 0
      self.position = max_position + 1
    end
  rescue
    # If restaurant is not yet saved, set a default position
    self.position ||= 0
  end

  def broadcast_create
    return unless restaurant_id
    
    # Broadcast to admin view using Turbo Streams
    broadcast_prepend_to "menu_updates_restaurant_#{restaurant_id}",
      partial: "menu_items/menu_item_card",
      locals: { menu_item: self, restaurant: restaurant },
      target: "menu_items_container"
    
    # Broadcast menu refresh for public view
    broadcast_menu_refresh
  end

  def broadcast_update
    return unless restaurant_id
    
    # Broadcast to admin view using Turbo Streams
    broadcast_replace_to "menu_updates_restaurant_#{restaurant_id}",
      partial: "menu_items/menu_item_card",
      locals: { menu_item: self, restaurant: restaurant },
      target: "menu_item_#{id}"
    
    # Broadcast menu refresh for public view (handles translations)
    broadcast_menu_refresh
  end

  def broadcast_destroy
    return unless restaurant_id
    
    # Broadcast to admin view using Turbo Streams
    broadcast_remove_to "menu_updates_restaurant_#{restaurant_id}",
      target: "menu_item_#{id}"
    
    # Broadcast menu refresh for public view
    broadcast_menu_refresh
  end

  def broadcast_menu_refresh
    return unless restaurant_id
    
    # Broadcast a refresh signal to update the entire menu
    ActionCable.server.broadcast(
      "menu_updates_restaurant_#{restaurant_id}",
      { action: "refresh_menu", restaurant_id: restaurant_id }
    )
  end
end

