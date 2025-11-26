class CreateRestaurantRegions < ActiveRecord::Migration[8.1]
  def change
    create_table :restaurant_regions do |t|
      t.references :restaurant, null: false, foreign_key: true
      t.references :region, null: false, foreign_key: true
      t.boolean :active, default: true
      t.date :registered_date
      t.text :compliance_notes

      t.timestamps
    end

    add_index :restaurant_regions, [:restaurant_id, :region_id], unique: true
    add_index :restaurant_regions, :active
  end
end

