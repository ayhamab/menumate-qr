class CreateSupplierReviews < ActiveRecord::Migration[8.1]
  def change
    create_table :supplier_reviews do |t|
      t.references :supplier, null: false, foreign_key: true
      t.references :restaurant, null: false, foreign_key: true
      t.integer :rating, null: false # 1-5
      t.text :comment
      t.boolean :approved, default: false

      t.timestamps
    end

    add_index :supplier_reviews, [:supplier_id, :restaurant_id], unique: true
    add_index :supplier_reviews, :approved
    add_index :supplier_reviews, :rating
  end
end

