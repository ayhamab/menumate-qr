class CreateSplitTestVariants < ActiveRecord::Migration[8.1]
  def change
    create_table :split_test_variants do |t|
      t.references :split_test, null: false, foreign_key: true
      t.string :name, null: false
      t.text :description # For description tests
      t.integer :position # For placement tests
      t.decimal :price, precision: 10, scale: 2 # For price tests
      t.integer :weight, default: 50 # Traffic weight (0-100)
      t.boolean :is_control, default: false
      t.text :notes

      t.timestamps
    end
    
    add_index :split_test_variants, [:split_test_id, :is_control]
    add_index :split_test_variants, :weight
  end
end

