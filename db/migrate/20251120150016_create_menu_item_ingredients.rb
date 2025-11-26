class CreateMenuItemIngredients < ActiveRecord::Migration[8.1]
  def change
    create_table :menu_item_ingredients do |t|
      t.references :menu_item, null: false, foreign_key: true
      t.references :ingredient, null: false, foreign_key: true
      t.string :quantity # e.g., "2 cups", "1 tbsp", "to taste"
      t.string :preparation_method # e.g., "chopped", "diced", "raw"

      t.timestamps
    end

    add_index :menu_item_ingredients, [:menu_item_id, :ingredient_id], unique: true
  end
end
