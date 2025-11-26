class Region < ApplicationRecord
  has_many :region_dietary_laws, dependent: :destroy
  has_many :dietary_laws, through: :region_dietary_laws
  has_many :restaurant_regions, dependent: :destroy
  has_many :restaurants, through: :restaurant_regions
  has_many :menu_item_compliances, dependent: :destroy

  # Validations
  validates :name, presence: true, uniqueness: true, length: { maximum: 255 }
  validates :code, presence: true, uniqueness: true, length: { maximum: 10 }
  validates :country_code, presence: true, length: { is: 2 }
  validates :region_type, inclusion: {
    in: %w[country state province city other]
  }

  # Scopes
  scope :active, -> { where(active: true) }
  scope :by_type, ->(type) { where(region_type: type) if type.present? }
  scope :by_country, ->(country) { where(country_code: country) if country.present? }
  scope :countries, -> { where(region_type: 'country') }
  scope :ordered, -> { order(:name) }

  # Instance methods
  def active?
    active == true
  end

  def country?
    region_type == 'country'
  end

  def state?
    region_type == 'state'
  end

  def mandatory_laws
    dietary_laws.active.mandatory
  end

  def all_laws
    dietary_laws.active
  end

  def check_menu_item_compliance(menu_item)
    results = {}
    all_laws.each do |law|
      compliance_result = law.check_compliance(menu_item)
      results[law.code] = compliance_result
    end
    {
      region: self,
      compliant: results.values.all? { |r| r[:compliant] },
      results: results,
      violations: results.values.flat_map { |r| r[:violations] }
    }
  end
end

