class ApiKey < ApplicationRecord
  belongs_to :user

  # Validations
  validates :token, presence: true, uniqueness: true
  validates :name, presence: true, length: { maximum: 100 }

  # Callbacks
  before_validation :generate_token, on: :create
  before_validation :set_default_expires_at, on: :create

  # Scopes
  scope :active, -> { where(active: true).where('expires_at IS NULL OR expires_at > ?', Time.current) }
  scope :expired, -> { where('expires_at IS NOT NULL AND expires_at <= ?', Time.current) }

  # Class methods
  def self.generate_unique_token
    loop do
      token = SecureRandom.hex(32)
      break token unless exists?(token: token)
    end
  end

  # Instance methods
  def expired?
    expires_at.present? && expires_at <= Time.current
  end

  def valid?
    active? && !expired?
  end

  def record_usage
    touch(:last_used_at)
    increment!(:usage_count)
  end

  private

  def generate_token
    self.token ||= self.class.generate_unique_token
  end

  def set_default_expires_at
    # Default to 1 year from creation if not specified
    self.expires_at ||= 1.year.from_now if expires_at.nil?
  end
end
