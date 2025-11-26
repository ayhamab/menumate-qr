class CreateTrainingSessions < ActiveRecord::Migration[8.1]
  def change
    create_table :training_sessions do |t|
      t.references :training_module, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.references :restaurant, null: true, foreign_key: true
      t.string :status, default: 'in_progress' # in_progress, completed, passed, failed
      t.decimal :score, precision: 5, scale: 2
      t.datetime :started_at
      t.datetime :completed_at
      t.integer :time_spent_seconds

      t.timestamps
    end
    
    add_index :training_sessions, [:user_id, :training_module_id]
    add_index :training_sessions, [:restaurant_id, :status]
    add_index :training_sessions, :status
  end
end

