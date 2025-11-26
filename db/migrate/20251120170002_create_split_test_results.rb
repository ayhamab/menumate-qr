class CreateSplitTestResults < ActiveRecord::Migration[8.1]
  def change
    create_table :split_test_results do |t|
      t.references :split_test, null: false, foreign_key: true
      t.references :split_test_variant, null: false, foreign_key: true
      t.string :event_type, null: false # impression, click, order
      t.string :session_id, null: false
      t.string :ip_address
      t.text :user_agent
      t.decimal :revenue, precision: 10, scale: 2 # For order events

      t.timestamps
    end
    
    add_index :split_test_results, [:split_test_id, :event_type]
    add_index :split_test_results, [:split_test_variant_id, :event_type]
    add_index :split_test_results, :session_id
    add_index :split_test_results, :created_at
  end
end

