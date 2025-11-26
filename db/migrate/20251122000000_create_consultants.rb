class CreateConsultants < ActiveRecord::Migration[8.1]
  def change
    create_table :consultants do |t|
      # Devise fields
      t.string :email, null: false, default: ""
      t.string :encrypted_password, null: false, default: ""
      t.string :reset_password_token
      t.datetime :reset_password_sent_at
      t.datetime :remember_created_at

      # Personal information
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :phone_number
      t.string :company_name
      t.text :bio
      t.text :specialties
      t.string :website
      
      # Status and verification
      t.boolean :verified, default: false
      t.string :status, default: 'pending' # pending, active, suspended, inactive
      
      # Social media
      t.string :linkedin_url
      t.string :twitter_url
      t.string :instagram_url

      t.timestamps
    end

    add_index :consultants, :email, unique: true
    add_index :consultants, :reset_password_token, unique: true
    add_index :consultants, :status
    add_index :consultants, :verified
  end
end

