class CreateIngredientListings < ActiveRecord::Migration[8.1]
  def change
    create_table :ingredient_listings do |t|
      t.references :supplier, null: false, foreign_key: true
      t.string :name, null: false
      t.text :description
      t.decimal :price_per_unit, precision: 10, scale: 2
      t.string :unit # lb, kg, case, box, etc.
      t.integer :minimum_order_quantity
      t.decimal :minimum_order_amount, precision: 10, scale: 2
      t.boolean :in_stock, default: true
      t.boolean :local, default: false
      t.boolean :organic, default: false
      t.boolean :featured, default: false
      t.string :status, default: 'draft' # draft, active, paused, sold_out
      t.text :dietary_info # JSON array
      t.text :certifications # JSON array
      t.text :storage_requirements
      t.text :shelf_life
      t.text :packaging_info
      t.integer :view_count, default: 0
      t.integer :contact_count, default: 0

      t.timestamps
    end

    add_index :ingredient_listings, [:supplier_id, :status]
    add_index :ingredient_listings, :status
    add_index :ingredient_listings, :featured
    add_index :ingredient_listings, :organic
    add_index :ingredient_listings, :local
  end
end

