class CreateTrainingCompletions < ActiveRecord::Migration[8.1]
  def change
    create_table :training_completions do |t|
      t.references :training_module, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.references :restaurant, null: true, foreign_key: true
      t.references :training_session, null: false, foreign_key: true
      t.datetime :completed_at
      t.decimal :score, precision: 5, scale: 2
      t.boolean :certified, default: false

      t.timestamps
    end
    
    add_index :training_completions, [:user_id, :training_module_id]
    add_index :training_completions, [:restaurant_id, :certified]
  end
end

