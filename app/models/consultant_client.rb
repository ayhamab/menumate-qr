class ConsultantClient < ApplicationRecord
  belongs_to :consultant
  belongs_to :restaurant

  # Validations
  validates :restaurant_id, uniqueness: {
    scope: :consultant_id,
    message: "is already a client of this consultant"
  }
  validates :status, inclusion: { in: %w[active paused terminated] }

  # Scopes
  scope :active, -> { where(status: 'active') }
  scope :paused, -> { where(status: 'paused') }
  scope :terminated, -> { where(status: 'terminated') }
  scope :recent, -> { order(created_at: :desc) }

  # Instance methods
  def active?
    status == 'active'
  end

  def paused?
    status == 'paused'
  end

  def terminated?
    status == 'terminated'
  end

  def can_perform_action?(action_type)
    return false unless active?
    
    case action_type.to_s
    when 'view'
      can_view
    when 'edit_menu'
      can_edit_menu
    when 'edit_settings'
      can_edit_settings
    when 'manage_team'
      can_manage_team
    when 'view_analytics'
      can_view_analytics
    else
      false
    end
  end
end

