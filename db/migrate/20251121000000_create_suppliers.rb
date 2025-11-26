class CreateSuppliers < ActiveRecord::Migration[8.1]
  def change
    create_table :suppliers do |t|
      # Devise fields
      t.string :email, null: false, default: ""
      t.string :encrypted_password, null: false, default: ""
      t.string :reset_password_token
      t.datetime :reset_password_sent_at
      t.datetime :remember_created_at

      # Company information
      t.string :company_name, null: false
      t.string :contact_name, null: false
      t.string :phone_number
      t.text :address, null: false
      t.string :city
      t.string :state
      t.string :zip_code
      t.string :country, default: 'US'
      t.string :website
      
      # Business details
      t.string :business_type # wholesaler, distributor, manufacturer, farm, local_producer, specialty_importer, other
      t.text :description
      t.text :specialties
      t.boolean :verified, default: false
      t.boolean :featured, default: false
      t.string :status, default: 'pending' # pending, active, suspended, inactive
      
      # Certifications
      t.text :certifications # JSON array
      t.text :delivery_areas # JSON array
      t.decimal :minimum_order_amount, precision: 10, scale: 2
      
      # Social media
      t.string :facebook_url
      t.string :instagram_url
      t.string :twitter_url
      t.string :linkedin_url

      t.timestamps
    end

    add_index :suppliers, :email, unique: true
    add_index :suppliers, :reset_password_token, unique: true
    add_index :suppliers, :status
    add_index :suppliers, :verified
    add_index :suppliers, :featured
    add_index :suppliers, :business_type
  end
end

