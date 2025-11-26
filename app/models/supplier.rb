class Supplier < ApplicationRecord
  # Include default devise modules for supplier authentication
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :ingredient_listings, dependent: :destroy
  has_many :supplier_promotions, dependent: :destroy
  has_many :supplier_contacts, dependent: :destroy
  has_many :supplier_reviews, dependent: :destroy
  has_one_attached :logo
  has_one_attached :certification_document

  # Validations
  validates :company_name, presence: true, length: { maximum: 255 }
  validates :contact_name, presence: true, length: { maximum: 100 }
  validates :email, presence: true, uniqueness: true
  validates :phone_number, format: {
    with: /\A[\d\s\(\)\-\+\.]+\z/,
    message: "contains invalid characters"
  }, allow_blank: true
  validates :address, presence: true, length: { maximum: 500 }
  validates :business_type, inclusion: {
    in: %w[wholesaler distributor manufacturer farm local_producer specialty_importer other],
    allow_blank: true
  }
  validates :status, inclusion: { in: %w[pending active suspended inactive] }

  # Scopes
  scope :active, -> { where(status: 'active') }
  scope :verified, -> { where(verified: true) }
  scope :by_business_type, ->(type) { where(business_type: type) if type.present? }
  scope :featured, -> { where(featured: true) }
  scope :recent, -> { order(created_at: :desc) }

  # Instance methods
  def active?
    status == 'active'
  end

  def verified?
    verified == true
  end

  def featured?
    featured == true
  end

  def display_name
    company_name
  end

  def average_rating
    return 0 if supplier_reviews.empty?
    supplier_reviews.average(:rating).round(2)
  end

  def total_reviews
    supplier_reviews.count
  end

  def active_ingredient_count
    ingredient_listings.active.count
  end

  def active_promotions_count
    supplier_promotions.active.count
  end

  def can_contact?
    active? && verified?
  end
end

