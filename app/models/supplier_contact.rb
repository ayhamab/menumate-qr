class SupplierContact < ApplicationRecord
  belongs_to :supplier
  belongs_to :restaurant, optional: true
  belongs_to :ingredient_listing, optional: true

  # Contact types: inquiry, quote_request, order, general
  validates :contact_type, inclusion: {
    in: %w[inquiry quote_request order general]
  }
  validates :name, presence: true, length: { maximum: 100 }
  validates :email, presence: true
  validates :message, presence: true, length: { maximum: 2000 }

  # Scopes
  scope :unread, -> { where(read: false) }
  scope :read, -> { where(read: true) }
  scope :by_type, ->(type) { where(contact_type: type) if type.present? }
  scope :recent, -> { order(created_at: :desc) }

  # Instance methods
  def mark_as_read!
    update(read: true, read_at: Time.current)
  end

  def unread?
    !read?
  end
end

