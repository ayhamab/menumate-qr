class CreateIngredientListingCategories < ActiveRecord::Migration[8.1]
  def change
    create_table :ingredient_listing_categories do |t|
      t.references :ingredient_listing, null: false, foreign_key: true
      t.references :category, null: false, foreign_key: true

      t.timestamps
    end

    add_index :ingredient_listing_categories, [:ingredient_listing_id, :category_id], 
              unique: true, name: 'index_ingredient_listing_categories_unique'
  end
end

