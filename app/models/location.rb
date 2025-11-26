class Location < ApplicationRecord
  belongs_to :restaurant
  has_many :menu_items, dependent: :nullify
  has_many :qr_codes, dependent: :destroy
  has_many :qr_scans, through: :qr_codes
  has_many :demographic_data, dependent: :destroy
  has_many :menu_syncs, dependent: :destroy
  has_many :location_menu_overrides, dependent: :destroy

  # Validations
  validates :name, presence: true, length: { maximum: 100 }
  validates :address, presence: true, length: { maximum: 255 }
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
  validates :phone_number, format: { 
    with: /\A[\d\s\(\)\-\+\.]+\z/, 
    message: "contains invalid characters" 
  }, allow_blank: true

  # Scopes
  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }

  # Instance methods
  def display_name
    "#{restaurant.name} - #{name}"
  end

  def full_address
    "#{address}, #{restaurant.address.split(',').last&.strip}" rescue address
  end

  def qr_code_url
    restaurant.qr_codes.first&.token || restaurant.generate_qr_code.token
  end

  # Calculate distance to coordinates (in kilometers)
  def distance_to(latitude, longitude)
    return nil if self.latitude.nil? || self.longitude.nil? || latitude.nil? || longitude.nil?
    
    # Haversine formula
    earth_radius = 6371 # km
    
    d_lat = (latitude - self.latitude) * Math::PI / 180
    d_lon = (longitude - self.longitude) * Math::PI / 180
    
    a = Math.sin(d_lat / 2) ** 2 +
        Math.cos(self.latitude * Math::PI / 180) *
        Math.cos(latitude * Math::PI / 180) *
        Math.sin(d_lon / 2) ** 2
    
    c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))
    
    (earth_radius * c).round(2)
  end

  def has_coordinates?
    latitude.present? && longitude.present?
  end
end
