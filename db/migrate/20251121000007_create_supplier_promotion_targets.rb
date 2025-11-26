class CreateSupplierPromotionTargets < ActiveRecord::Migration[8.1]
  def change
    create_table :supplier_promotion_targets do |t|
      t.references :supplier_promotion, null: false, foreign_key: true
      t.references :restaurant, null: false, foreign_key: true

      t.timestamps
    end

    add_index :supplier_promotion_targets, [:supplier_promotion_id, :restaurant_id],
              unique: true, name: 'index_supplier_promotion_targets_unique'
  end
end

