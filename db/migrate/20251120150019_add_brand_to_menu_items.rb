class AddBrandToMenuItems < ActiveRecord::Migration[8.1]
  def change
    add_reference :menu_items, :brand, null: true, foreign_key: true
  end
end
