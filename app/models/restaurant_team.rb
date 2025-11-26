class RestaurantTeam < ApplicationRecord
  belongs_to :restaurant
  belongs_to :user

  # Roles: owner, chef, manager, staff
  validates :role, inclusion: { in: %w[owner chef manager staff] }
  validates :user_id, uniqueness: { scope: :restaurant_id, message: "is already a team member" }

  # Scopes
  scope :active, -> { where(active: true) }
  scope :owners, -> { where(role: 'owner') }
  scope :chefs, -> { where(role: 'chef') }
  scope :managers, -> { where(role: ['owner', 'chef', 'manager']) }
  scope :staff, -> { where(role: ['chef', 'manager', 'staff']) }

  # Instance methods
  def owner?
    role == 'owner'
  end

  def chef?
    role == 'chef'
  end

  def manager?
    role == 'manager' || role == 'chef' || role == 'owner'
  end

  def staff?
    role == 'staff' || role == 'manager' || role == 'chef' || role == 'owner'
  end

  def can_edit_menu_items?
    manager?
  end

  def can_delete_menu_items?
    owner? || chef?
  end

  def can_manage_team?
    owner? || (role == 'manager')
  end

  def can_view_analytics?
    manager?
  end

  def can_approve_changes?
    owner? || chef?
  end
end

