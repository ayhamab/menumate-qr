class MenuTemplate < ApplicationRecord
  belongs_to :corporate_account
  has_many :menu_template_items, dependent: :destroy
  has_many :menu_syncs, dependent: :destroy
  has_many :location_menu_overrides, dependent: :destroy

  # Validations
  validates :name, presence: true, length: { maximum: 255 }
  validates :version, presence: true
  validates :status, inclusion: {
    in: %w[draft active archived]
  }

  # Serialize settings as JSON
  serialize :settings, coder: JSON

  # Scopes
  scope :active, -> { where(status: 'active') }
  scope :draft, -> { where(status: 'draft') }
  scope :archived, -> { where(status: 'archived') }
  scope :latest, -> { order(version: :desc) }
  scope :by_corporate_account, ->(account) { where(corporate_account: account) if account.present? }

  # Instance methods
  def active?
    status == 'active'
  end

  def draft?
    status == 'draft'
  end

  def archived?
    status == 'archived'
  end

  def can_edit?
    draft? || active?
  end

  def menu_items_count
    menu_template_items.count
  end

  def categories
    menu_template_items.pluck(:category).uniq.compact
  end

  def total_price_range
    prices = menu_template_items.pluck(:price).compact
    return nil if prices.empty?
    { min: prices.min, max: prices.max, avg: (prices.sum / prices.count).round(2) }
  end

  def sync_to_locations(location_ids = nil)
    locations = corporate_account.restaurants.includes(:locations).flat_map(&:locations)
    locations = locations.select { |loc| location_ids.include?(loc.id) } if location_ids.present?
    
    syncs = []
    locations.each do |location|
      sync = MenuSync.create(
        menu_template: self,
        location: location,
        status: 'pending',
        sync_type: 'full'
      )
      syncs << sync
    end
    
    syncs
  end

  def create_new_version
    new_template = dup
    new_template.version = increment_version
    new_template.status = 'draft'
    new_template.save
    
    # Copy menu items
    menu_template_items.each do |item|
      new_item = item.dup
      new_item.menu_template = new_template
      new_item.save
    end
    
    new_template
  end

  def increment_version
    parts = version.split('.')
    parts[-1] = (parts[-1].to_i + 1).to_s
    parts.join('.')
  end

  def consistency_report(locations = nil)
    locations ||= corporate_account.restaurants.includes(:locations).flat_map(&:locations)
    
    {
      total_locations: locations.count,
      synced_locations: menu_syncs.where(status: 'completed', location: locations).count,
      pending_syncs: menu_syncs.where(status: 'pending', location: locations).count,
      failed_syncs: menu_syncs.where(status: 'failed', location: locations).count,
      locations_with_overrides: location_menu_overrides.where(location: locations).select(:location_id).distinct.count,
      consistency_score: calculate_consistency_score(locations)
    }
  end

  private

  def calculate_consistency_score(locations)
    return 0 if locations.empty?
    
    synced_count = menu_syncs.where(status: 'completed', location: locations).count
    (synced_count.to_f / locations.count * 100).round(2)
  end
end

