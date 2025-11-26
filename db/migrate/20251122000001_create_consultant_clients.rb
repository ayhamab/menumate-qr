class CreateConsultantClients < ActiveRecord::Migration[8.1]
  def change
    create_table :consultant_clients do |t|
      t.references :consultant, null: false, foreign_key: true
      t.references :restaurant, null: false, foreign_key: true
      
      # Permissions
      t.boolean :can_view, default: true
      t.boolean :can_edit_menu, default: false
      t.boolean :can_edit_settings, default: false
      t.boolean :can_manage_team, default: false
      t.boolean :can_view_analytics, default: true
      
      # Relationship details
      t.string :status, default: 'active' # active, paused, terminated
      t.date :start_date
      t.date :end_date
      t.text :notes
      t.decimal :monthly_fee, precision: 10, scale: 2
      t.string :contract_type # hourly, monthly, project_based

      t.timestamps
    end

    add_index :consultant_clients, [:consultant_id, :restaurant_id], unique: true
    add_index :consultant_clients, :status
  end
end

