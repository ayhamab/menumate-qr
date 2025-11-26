class CreateLocationMenuOverrides < ActiveRecord::Migration[8.1]
  def change
    create_table :location_menu_overrides do |t|
      t.references :menu_template, null: false, foreign_key: true
      t.references :menu_template_item, null: true, foreign_key: true
      t.references :location, null: false, foreign_key: true
      t.references :created_by, null: true, foreign_key: { to_table: :users }
      t.references :approved_by, null: true, foreign_key: { to_table: :users }
      
      t.string :action, null: false # exclude, modify_price, modify_description, add_custom
      t.string :status, default: 'pending' # pending, approved, rejected
      t.text :override_attributes # JSON
      t.text :reason
      t.text :rejection_reason
      t.datetime :approved_at

      t.timestamps
    end

    add_index :location_menu_overrides, [:menu_template_id, :location_id]
    add_index :location_menu_overrides, [:menu_template_item_id, :location_id]
    add_index :location_menu_overrides, :status
    add_index :location_menu_overrides, :action
  end
end

