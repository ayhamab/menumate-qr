class CreateIngredients < ActiveRecord::Migration[8.1]
  def change
    create_table :ingredients do |t|
      t.string :name, null: false
      t.string :allergen_type # nuts, peanuts, shellfish, fish, eggs, milk, soy, wheat, sesame, sulfites, none
      t.string :preparation_area # grill, fryer, oven, stovetop, prep_station, etc.
      t.text :notes

      t.timestamps
    end

    add_index :ingredients, :name, unique: true
    add_index :ingredients, :allergen_type
    add_index :ingredients, :preparation_area
  end
end
