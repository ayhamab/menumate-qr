class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :restaurants, dependent: :destroy
  has_many :corporate_account_users, dependent: :destroy
  has_many :corporate_accounts, through: :corporate_account_users
  has_many :api_keys, dependent: :destroy
  has_many :restaurant_teams, dependent: :destroy
  has_many :team_restaurants, through: :restaurant_teams, source: :restaurant
  has_many :menu_item_assignments, foreign_key: 'assigned_to_id', dependent: :destroy
  has_many :menu_item_comments, dependent: :destroy
  has_many :training_sessions, dependent: :destroy
  has_many :training_completions, dependent: :destroy
  has_many :completed_training_modules, through: :training_completions, source: :training_module

  # Instance methods
  def corporate_accounts_managed
    corporate_accounts.joins(:corporate_account_users)
                     .where(corporate_account_users: { role: ['admin', 'manager'], active: true })
  end

  def belongs_to_corporate_account?
    corporate_accounts.active.exists?
  end
end

