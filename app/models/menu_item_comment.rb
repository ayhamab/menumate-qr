class MenuItemComment < ApplicationRecord
  belongs_to :menu_item
  belongs_to :user
  belongs_to :parent, class_name: 'MenuItemComment', optional: true

  has_many :replies, class_name: 'MenuItemComment', foreign_key: 'parent_id', dependent: :destroy

  validates :content, presence: true, length: { minimum: 1, maximum: 1000 }

  # Scopes
  scope :top_level, -> { where(parent_id: nil) }
  scope :recent, -> { order(created_at: :desc) }
  scope :by_user, ->(user) { where(user: user) if user.present? }

  # Instance methods
  def top_level?
    parent_id.nil?
  end

  def reply?
    parent_id.present?
  end

  def has_replies?
    replies.any?
  end
end

