class CreateRecipes < ActiveRecord::Migration[8.1]
  def change
    create_table :recipes do |t|
      t.references :restaurant, null: false, foreign_key: true
      t.references :menu_item, null: true, foreign_key: true
      t.string :name, null: false
      t.text :description
      t.text :instructions
      t.integer :base_servings, null: false, default: 1
      t.integer :prep_time # in minutes
      t.integer :cook_time # in minutes
      t.string :difficulty # easy, medium, hard
      t.text :notes

      t.timestamps
    end
    
    add_index :recipes, [:restaurant_id, :name]
    add_index :recipes, :menu_item_id unless index_exists?(:recipes, :menu_item_id)
  end
end

