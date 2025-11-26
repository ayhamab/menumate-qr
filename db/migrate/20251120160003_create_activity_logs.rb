class CreateActivityLogs < ActiveRecord::Migration[8.1]
  def change
    create_table :activity_logs do |t|
      t.references :restaurant, null: false, foreign_key: true
      t.references :user, null: true, foreign_key: true
      t.references :trackable, polymorphic: true, null: true
      t.string :activity_type, null: false
      t.json :metadata

      t.timestamps
    end
    
    add_index :activity_logs, [:restaurant_id, :created_at]
    add_index :activity_logs, :activity_type
    add_index :activity_logs, [:trackable_type, :trackable_id]
  end
end

