class AddCategoryAndPositionToMenuItems < ActiveRecord::Migration[8.1]
  def change
    add_column :menu_items, :category, :string
    add_column :menu_items, :position, :integer, default: 0
    add_index :menu_items, :category
    add_index :menu_items, [:restaurant_id, :category, :position]
  end
end

