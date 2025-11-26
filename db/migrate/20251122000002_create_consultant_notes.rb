class CreateConsultantNotes < ActiveRecord::Migration[8.1]
  def change
    create_table :consultant_notes do |t|
      t.references :consultant, null: false, foreign_key: true
      t.references :restaurant, null: true, foreign_key: true
      t.references :menu_item, null: true, foreign_key: true
      
      t.string :note_type, null: false # general, menu_item, restaurant, task, meeting
      t.text :content, null: false
      t.boolean :pinned, default: false
      t.text :tags # JSON array

      t.timestamps
    end

    add_index :consultant_notes, [:consultant_id, :restaurant_id]
    add_index :consultant_notes, :note_type
    add_index :consultant_notes, :pinned
  end
end

