class CreateMenuItemCompliances < ActiveRecord::Migration[8.1]
  def change
    create_table :menu_item_compliances do |t|
      t.references :menu_item, null: false, foreign_key: true
      t.references :dietary_law, null: false, foreign_key: true
      t.references :region, null: true, foreign_key: true
      
      t.string :status, default: 'pending_review' # compliant, non_compliant, pending_review, exempt
      t.text :violations # JSON array
      t.text :notes # JSON
      t.datetime :last_checked_at
      t.string :checked_by # system, consultant, admin
      t.boolean :certified, default: false
      t.string :certification_number

      t.timestamps
    end

    add_index :menu_item_compliances, [:menu_item_id, :dietary_law_id, :region_id], 
              unique: true, name: 'index_menu_item_compliances_unique'
    add_index :menu_item_compliances, :status
    add_index :menu_item_compliances, :certified
    add_index :menu_item_compliances, :last_checked_at
  end
end

