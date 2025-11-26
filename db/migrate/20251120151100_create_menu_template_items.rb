class CreateMenuTemplateItems < ActiveRecord::Migration[8.1]
  def change
    create_table :menu_template_items do |t|
      t.references :menu_template, null: false, foreign_key: true
      t.string :name, null: false
      t.text :description
      t.decimal :price, precision: 10, scale: 2, null: false
      t.string :category
      t.text :dietary_tags # JSON array
      t.text :allergens # JSON array
      t.text :name_translations # JSON
      t.text :description_translations # JSON
      t.integer :display_order, default: 0
      t.boolean :active, default: true
      t.text :notes

      t.timestamps
    end

    add_index :menu_template_items, [:menu_template_id, :display_order]
    add_index :menu_template_items, :category
    add_index :menu_template_items, :active
  end
end

