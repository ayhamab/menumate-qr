class CreateMenuItemAssignments < ActiveRecord::Migration[8.1]
  def change
    create_table :menu_item_assignments do |t|
      t.references :menu_item, null: false, foreign_key: true
      t.references :assigned_to, null: false, foreign_key: { to_table: :users }
      t.references :assigned_by, null: true, foreign_key: { to_table: :users }
      t.string :status, default: 'pending' # pending, in_progress, completed, reviewed
      t.string :priority # low, medium, high, urgent
      t.text :notes
      t.datetime :started_at
      t.datetime :completed_at
      t.datetime :reviewed_at
      t.datetime :due_date

      t.timestamps
    end
    
    add_index :menu_item_assignments, :status
    add_index :menu_item_assignments, :priority
    add_index :menu_item_assignments, :assigned_to_id unless index_exists?(:menu_item_assignments, :assigned_to_id)
  end
end

