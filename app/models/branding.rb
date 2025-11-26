class Branding < ApplicationRecord
  belongs_to :restaurant
  has_one_attached :logo
  has_one_attached :favicon

  # Validations
  validates :primary_color, :secondary_color, :accent_color, format: { 
    with: /\A#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})\z/, 
    message: "must be a valid hex color code" 
  }, allow_blank: true
  validate :validate_logo_content_type
  validate :validate_logo_size
  validate :validate_favicon_content_type
  validate :validate_favicon_size
  validates :custom_css, length: { maximum: 10000, message: 'must be less than 10000 characters' }, allow_blank: true

  # Default values
  after_initialize :set_defaults, if: :new_record?

  # Instance methods
  def has_custom_branding?
    primary_color.present? || secondary_color.present? || logo.attached? || custom_css.present?
  end

  def display_name
    company_name.presence || restaurant.name
  end

  def css_variables
    {
      '--primary-color' => primary_color || '#4F46E5',
      '--secondary-color' => secondary_color || '#7C3AED',
      '--accent-color' => accent_color || '#EC4899',
      '--font-family' => font_family || 'Inter, system-ui, sans-serif'
    }
  end

  def inline_styles
    css_variables.map { |key, value| "#{key}: #{value}" }.join('; ')
  end

  private

  def set_defaults
    self.primary_color ||= '#4F46E5'
    self.secondary_color ||= '#7C3AED'
    self.accent_color ||= '#EC4899'
    self.font_family ||= 'Inter, system-ui, sans-serif'
  end

  def validate_logo_content_type
    return unless logo.attached?
    
    valid_types = ['image/png', 'image/jpeg', 'image/jpg', 'image/svg+xml', 'image/webp']
    unless valid_types.include?(logo.blob.content_type)
      errors.add(:logo, 'must be a valid image format (PNG, JPEG, SVG, or WebP)')
    end
  end

  def validate_logo_size
    return unless logo.attached?
    
    max_size = 5.megabytes
    if logo.blob.byte_size > max_size
      errors.add(:logo, "must be less than 5MB")
    end
  end

  def validate_favicon_content_type
    return unless favicon.attached?
    
    valid_types = ['image/png', 'image/jpeg', 'image/jpg', 'image/x-icon', 'image/svg+xml']
    unless valid_types.include?(favicon.blob.content_type)
      errors.add(:favicon, 'must be a valid favicon format (PNG, JPEG, ICO, or SVG)')
    end
  end

  def validate_favicon_size
    return unless favicon.attached?
    
    max_size = 1.megabyte
    if favicon.blob.byte_size > max_size
      errors.add(:favicon, "must be less than 1MB")
    end
  end
end
