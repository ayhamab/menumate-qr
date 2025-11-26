class CreateBrandAnalytics < ActiveRecord::Migration[8.1]
  def change
    create_table :brand_analytics do |t|
      t.string :brand_name, null: false
      t.string :email, null: false
      t.string :subscription_tier, default: 'basic' # basic, premium, enterprise
      t.string :api_key, null: false
      t.boolean :active, default: true
      t.text :notes # Admin notes
      t.datetime :last_access_at
      t.integer :api_calls_count, default: 0
      t.decimal :monthly_fee, precision: 10, scale: 2, default: 0

      t.timestamps
    end
    
    add_index :brand_analytics, :api_key, unique: true
    add_index :brand_analytics, :email
    add_index :brand_analytics, :active
  end
end
