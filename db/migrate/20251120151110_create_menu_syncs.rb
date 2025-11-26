class CreateMenuSyncs < ActiveRecord::Migration[8.1]
  def change
    create_table :menu_syncs do |t|
      t.references :menu_template, null: false, foreign_key: true
      t.references :location, null: false, foreign_key: true
      t.references :initiated_by, null: true, foreign_key: { to_table: :users }
      
      t.string :status, default: 'pending' # pending, in_progress, completed, failed, cancelled
      t.string :sync_type, default: 'full' # full, incremental, selective
      t.text :sync_details # JSON
      t.text :error_message
      t.datetime :started_at
      t.datetime :completed_at

      t.timestamps
    end

    add_index :menu_syncs, [:menu_template_id, :location_id]
    add_index :menu_syncs, :status
    add_index :menu_syncs, :sync_type
  end
end

