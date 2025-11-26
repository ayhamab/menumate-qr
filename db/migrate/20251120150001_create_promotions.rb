class CreatePromotions < ActiveRecord::Migration[8.1]
  def change
    create_table :promotions do |t|
      t.references :restaurant, null: false, foreign_key: true
      t.string :title, null: false
      t.text :description
      t.string :discount_type, null: false # 'percentage', 'fixed_amount', 'special'
      t.decimal :discount_value, precision: 10, scale: 2
      t.datetime :start_date, null: false
      t.datetime :end_date, null: false
      t.boolean :active, default: true
      t.string :badge_color, default: 'red' # For visual styling

      t.timestamps
    end
    
    add_index :promotions, :active
    add_index :promotions, [:start_date, :end_date]
    
    # Join table for promotions and menu_items (many-to-many)
    create_table :menu_item_promotions do |t|
      t.references :menu_item, null: false, foreign_key: true
      t.references :promotion, null: false, foreign_key: true
      
      t.timestamps
    end
    
    add_index :menu_item_promotions, [:menu_item_id, :promotion_id], unique: true
  end
end
