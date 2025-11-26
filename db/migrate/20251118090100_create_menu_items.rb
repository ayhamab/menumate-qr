class CreateMenuItems < ActiveRecord::Migration[8.1]
  def change
    create_table :menu_items do |t|
      t.string :name, null: false
      t.text :description
      t.decimal :price, precision: 8, scale: 2, null: false, default: 0
      t.string :dietary_tags
      t.references :restaurant, null: false, foreign_key: true

      t.timestamps
    end

    add_index :menu_items, :name
  end
end

