class CreateSplitTests < ActiveRecord::Migration[8.1]
  def change
    create_table :split_tests do |t|
      t.references :restaurant, null: false, foreign_key: true
      t.references :menu_item, null: true, foreign_key: true
      t.string :name, null: false
      t.string :test_type, null: false # description, placement, image, price
      t.string :status, default: 'draft' # draft, active, paused, completed
      t.boolean :auto_apply_winner, default: false
      t.bigint :winner_variant_id, null: true
      t.datetime :started_at
      t.datetime :completed_at
      t.text :notes

      t.timestamps
    end
    
    add_index :split_tests, :status
    add_index :split_tests, :test_type
    add_index :split_tests, [:restaurant_id, :status]
  end
end

