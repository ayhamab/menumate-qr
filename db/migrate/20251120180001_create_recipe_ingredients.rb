class CreateRecipeIngredients < ActiveRecord::Migration[8.1]
  def change
    create_table :recipe_ingredients do |t|
      t.references :recipe, null: false, foreign_key: true
      t.references :ingredient, null: false, foreign_key: true
      t.decimal :quantity, precision: 10, scale: 2, null: false
      t.string :unit # cups, tbsp, tsp, oz, lb, g, kg, pieces, etc.
      t.string :preparation_method # chopped, diced, minced, etc.
      t.integer :position, default: 0
      t.text :notes

      t.timestamps
    end
    
    add_index :recipe_ingredients, [:recipe_id, :ingredient_id], unique: true
    add_index :recipe_ingredients, :position
  end
end

