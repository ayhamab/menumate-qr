class CreateTrainingModules < ActiveRecord::Migration[8.1]
  def change
    create_table :training_modules do |t|
      t.references :restaurant, null: true, foreign_key: true
      t.string :title, null: false
      t.text :description
      t.text :content
      t.string :module_type, null: false # dietary_requirements, allergy_safety, food_handling, customer_service, general
      t.integer :position, default: 0
      t.integer :passing_score, default: 80
      t.integer :certification_valid_days # Days until certification expires
      t.boolean :active, default: true
      t.boolean :required, default: false
      t.text :learning_objectives
      t.text :notes

      t.timestamps
    end
    
    add_index :training_modules, [:restaurant_id, :module_type]
    add_index :training_modules, :active
    add_index :training_modules, :required
    add_index :training_modules, :position
  end
end

