class CreateBrands < ActiveRecord::Migration[8.1]
  def change
    create_table :brands do |t|
      t.references :restaurant, null: false, foreign_key: true
      t.string :name, null: false
      t.text :description
      t.string :logo_url
      t.string :brand_color # Hex color code
      t.boolean :active, default: true, null: false
      t.integer :display_order, default: 0, null: false

      t.timestamps
    end

    add_index :brands, [:restaurant_id, :display_order]
    add_index :brands, :active
    add_index :brands, :name
  end
end
