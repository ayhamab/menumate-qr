class Brand < ApplicationRecord
  belongs_to :restaurant
  has_many :menu_items, dependent: :nullify
  has_many :qr_codes, dependent: :nullify
  has_many :promotions, dependent: :nullify

  # Validations
  validates :name, presence: true, length: { maximum: 100 }
  validates :description, length: { maximum: 1000 }, allow_blank: true
  validates :brand_color, format: { with: /\A#[0-9A-Fa-f]{6}\z/, message: "must be a valid hex color" }, allow_blank: true
  validates :display_order, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  # Scopes
  scope :active, -> { where(active: true) }
  scope :ordered, -> { order(:display_order, :name) }

  # Callbacks
  before_validation :set_default_display_order, on: :create

  # Instance methods
  def display_name
    name
  end

  def menu_url(host_with_port, protocol = 'http')
    "#{protocol}://#{host_with_port}/brands/#{id}/menu"
  end

  def qr_code_url
    qr_codes.active.first&.token || generate_qr_code.token
  end

  def generate_qr_code
    menu_url = menu_brand_url(self, host: Rails.application.config.action_mailer.default_url_options[:host] || 'localhost:3000')
    qr_code = qr_codes.create!(
      token: SecureRandom.hex(16),
      name: "#{name} Menu QR Code",
      description: "QR code for #{name} menu"
    )
    qr_code
  end

  def menu_items_count
    menu_items.count
  end

  def active_menu_items_count
    menu_items.count
  end

  private

  def set_default_display_order
    self.display_order ||= (restaurant.brands.maximum(:display_order) || -1) + 1
  end
end
