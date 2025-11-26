class CorporateAccountUser < ApplicationRecord
  belongs_to :corporate_account
  belongs_to :user

  # Validations
  validates :role, inclusion: { in: %w[admin manager member] }
  validates :user_id, uniqueness: { scope: :corporate_account_id, message: "is already a member of this corporate account" }

  # Scopes
  scope :active, -> { where(active: true) }
  scope :admins, -> { where(role: 'admin') }
  scope :managers, -> { where(role: ['admin', 'manager']) }

  # Instance methods
  def admin?
    role == 'admin'
  end

  def manager?
    role == 'manager' || role == 'admin'
  end

  def member?
    role == 'member'
  end
end
