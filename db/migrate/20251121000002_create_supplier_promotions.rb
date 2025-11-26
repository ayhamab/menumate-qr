class CreateSupplierPromotions < ActiveRecord::Migration[8.1]
  def change
    create_table :supplier_promotions do |t|
      t.references :supplier, null: false, foreign_key: true
      t.string :title, null: false
      t.text :description
      t.string :promotion_type, null: false # discount, bulk_deal, seasonal_special, new_product, featured_ingredient
      t.decimal :discount_percentage, precision: 5, scale: 2
      t.decimal :discount_amount, precision: 10, scale: 2
      t.date :start_date, null: false
      t.date :end_date, null: false
      t.boolean :featured, default: false
      t.string :status, default: 'draft' # draft, active, paused, expired
      t.integer :view_count, default: 0
      t.integer :click_count, default: 0

      t.timestamps
    end

    add_index :supplier_promotions, [:supplier_id, :status]
    add_index :supplier_promotions, :status
    add_index :supplier_promotions, [:start_date, :end_date]
    add_index :supplier_promotions, :featured
  end
end

