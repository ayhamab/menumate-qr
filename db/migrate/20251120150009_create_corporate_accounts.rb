class CreateCorporateAccounts < ActiveRecord::Migration[8.1]
  def change
    create_table :corporate_accounts do |t|
      t.string :name, null: false
      t.string :email, null: false
      t.string :phone_number
      t.string :subscription_tier, default: 'enterprise' # enterprise, premium, basic
      t.boolean :active, default: true
      t.integer :max_restaurants, default: 10
      t.integer :max_locations_per_restaurant, default: 50
      t.text :notes
      t.string :billing_address
      t.string :tax_id

      t.timestamps
    end
    
    add_index :corporate_accounts, :email
    add_index :corporate_accounts, :active
  end
end
