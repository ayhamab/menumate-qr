class ActivityLog < ApplicationRecord
  belongs_to :restaurant
  belongs_to :user, optional: true
  belongs_to :trackable, polymorphic: true, optional: true

  # Activity types: menu_item_created, menu_item_updated, menu_item_deleted, 
  # team_member_added, team_member_removed, assignment_created, comment_added, etc.
  validates :activity_type, presence: true

  # Scopes
  scope :recent, -> { order(created_at: :desc) }
  scope :by_type, ->(type) { where(activity_type: type) if type.present? }
  scope :by_user, ->(user) { where(user: user) if user.present? }
  scope :for_restaurant, ->(restaurant) { where(restaurant: restaurant) if restaurant.present? }

  # Instance methods
  def description
    case activity_type
    when 'menu_item_created'
      "#{user_name} created menu item: #{trackable_name}"
    when 'menu_item_updated'
      "#{user_name} updated menu item: #{trackable_name}"
    when 'menu_item_deleted'
      "#{user_name} deleted menu item: #{metadata['item_name']}"
    when 'team_member_added'
      "#{user_name} added #{metadata['member_name']} to the team as #{metadata['role']}"
    when 'team_member_removed'
      "#{user_name} removed #{metadata['member_name']} from the team"
    when 'assignment_created'
      "#{user_name} assigned #{trackable_name} to #{metadata['assigned_to']}"
    when 'comment_added'
      "#{user_name} commented on #{trackable_name}"
    else
      metadata['description'] || "#{user_name} performed #{activity_type}"
    end
  end

  def user_name
    user&.email || 'System'
  end

  def trackable_name
    case trackable_type
    when 'MenuItem'
      trackable&.name || 'menu item'
    when 'RestaurantTeam'
      'team member'
    when 'MenuItemAssignment'
      trackable&.menu_item&.name || 'assignment'
    else
      trackable_type&.underscore&.humanize || 'item'
    end
  end
end

