class AddNutritionToMenuItems < ActiveRecord::Migration[8.1]
  def change
    add_column :menu_items, :calories, :integer
    add_column :menu_items, :protein, :decimal, precision: 10, scale: 2
    add_column :menu_items, :carbs, :decimal, precision: 10, scale: 2
    add_column :menu_items, :fat, :decimal, precision: 10, scale: 2
    add_column :menu_items, :fiber, :decimal, precision: 10, scale: 2
    add_column :menu_items, :sugar, :decimal, precision: 10, scale: 2
    add_column :menu_items, :sodium, :integer
    add_column :menu_items, :cholesterol, :integer
    add_column :menu_items, :nutrition_data, :text
    add_column :menu_items, :nutrition_api_provider, :string
    add_column :menu_items, :nutrition_last_updated, :datetime

    add_index :menu_items, :calories
  end
end
