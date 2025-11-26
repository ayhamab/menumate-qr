class Consultant < ApplicationRecord
  # Include default devise modules for consultant authentication
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :consultant_clients, dependent: :destroy
  has_many :restaurants, through: :consultant_clients
  has_many :consultant_notes, dependent: :destroy
  has_many :consultant_reports, dependent: :destroy
  has_many :consultant_tasks, dependent: :destroy
  has_one_attached :profile_image

  # Validations
  validates :first_name, presence: true, length: { maximum: 100 }
  validates :last_name, presence: true, length: { maximum: 100 }
  validates :email, presence: true, uniqueness: true
  validates :phone_number, format: {
    with: /\A[\d\s\(\)\-\+\.]+\z/,
    message: "contains invalid characters"
  }, allow_blank: true
  validates :company_name, length: { maximum: 255 }, allow_blank: true
  validates :status, inclusion: { in: %w[pending active suspended inactive] }

  # Scopes
  scope :active, -> { where(status: 'active') }
  scope :verified, -> { where(verified: true) }
  scope :recent, -> { order(created_at: :desc) }

  # Instance methods
  def active?
    status == 'active'
  end

  def verified?
    verified == true
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def display_name
    company_name.present? ? "#{company_name} - #{full_name}" : full_name
  end

  def client_count
    consultant_clients.active.count
  end

  def active_client_count
    consultant_clients.active.joins(:restaurant).where(restaurants: { active: true }).count
  end

  def total_menu_items_managed
    restaurants.sum { |r| r.menu_items.count }
  end

  def can_access_restaurant?(restaurant)
    consultant_clients.active.exists?(restaurant: restaurant)
  end

  def has_permission?(restaurant, permission_type)
    client = consultant_clients.active.find_by(restaurant: restaurant)
    return false unless client
    
    case permission_type.to_s
    when 'view'
      client.can_view
    when 'edit_menu'
      client.can_edit_menu
    when 'edit_settings'
      client.can_edit_settings
    when 'manage_team'
      client.can_manage_team
    when 'view_analytics'
      client.can_view_analytics
    else
      false
    end
  end
end

