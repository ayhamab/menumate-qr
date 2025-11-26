class CreateMenuItemAnalytics < ActiveRecord::Migration[8.1]
  def change
    create_table :menu_item_analytics do |t|
      t.references :menu_item, null: false, foreign_key: true
      t.references :restaurant, null: false, foreign_key: true
      t.date :date, null: false
      t.integer :views, default: 0
      t.integer :clicks, default: 0
      t.integer :orders, default: 0
      t.decimal :revenue, precision: 10, scale: 2, default: 0

      t.timestamps
    end
    
    add_index :menu_item_analytics, [:menu_item_id, :date], unique: true
    add_index :menu_item_analytics, [:restaurant_id, :date]
    add_index :menu_item_analytics, :date
  end
end

