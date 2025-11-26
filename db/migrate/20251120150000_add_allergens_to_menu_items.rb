class AddAllergensToMenuItems < ActiveRecord::Migration[8.1]
  def change
    add_column :menu_items, :allergens, :text
  end
end

