class ConsultantNote < ApplicationRecord
  belongs_to :consultant
  belongs_to :restaurant, optional: true
  belongs_to :menu_item, optional: true

  # Note types: general, menu_item, restaurant, task, meeting
  validates :note_type, inclusion: {
    in: %w[general menu_item restaurant task meeting]
  }
  validates :content, presence: true, length: { maximum: 5000 }

  # Scopes
  scope :by_type, ->(type) { where(note_type: type) if type.present? }
  scope :by_restaurant, ->(restaurant) { where(restaurant: restaurant) if restaurant.present? }
  scope :recent, -> { order(created_at: :desc) }
  scope :pinned, -> { where(pinned: true) }

  # Instance methods
  def pinned?
    pinned == true
  end

  def general?
    note_type == 'general'
  end

  def menu_item_note?
    note_type == 'menu_item'
  end

  def restaurant_note?
    note_type == 'restaurant'
  end
end

