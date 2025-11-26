# frozen_string_literal: true

class AddDeviseToUsers < ActiveRecord::Migration[8.1]
  def change
    # Remove old password_digest column (from has_secure_password)
    remove_column :users, :password_digest, :string, if_exists: true

    # Add Devise fields
    add_column :users, :encrypted_password, :string, null: false, default: ""
    add_column :users, :reset_password_token, :string
    add_column :users, :reset_password_sent_at, :datetime
    add_column :users, :remember_created_at, :datetime

    # Add index for reset_password_token
    add_index :users, :reset_password_token, unique: true
  end
end
