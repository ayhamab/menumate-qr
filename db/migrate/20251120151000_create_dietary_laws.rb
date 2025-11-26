class CreateDietaryLaws < ActiveRecord::Migration[8.1]
  def change
    create_table :dietary_laws do |t|
      t.string :name, null: false
      t.string :code, null: false
      t.string :law_type, null: false # halal, kosher, vegetarian_mandate, allergen_labeling, nutrition_labeling, organic_certification, gmo_labeling, alcohol_restrictions, other
      t.text :description
      t.text :requirements # JSON
      t.text :prohibited_ingredients # JSON array
      t.text :required_certifications # JSON array
      t.boolean :active, default: true
      t.boolean :mandatory, default: false
      t.text :legal_reference
      t.text :enforcement_notes

      t.timestamps
    end

    add_index :dietary_laws, :code, unique: true
    add_index :dietary_laws, :name, unique: true
    add_index :dietary_laws, :law_type
    add_index :dietary_laws, :active
    add_index :dietary_laws, :mandatory
  end
end

