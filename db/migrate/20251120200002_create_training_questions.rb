class CreateTrainingQuestions < ActiveRecord::Migration[8.1]
  def change
    create_table :training_questions do |t|
      t.references :training_module, null: false, foreign_key: true
      t.text :question_text, null: false
      t.string :question_type, null: false # multiple_choice, true_false, multiple_select
      t.json :options # Array of answer options
      t.json :correct_option # Correct answer(s)
      t.text :explanation
      t.integer :position, default: 0
      t.text :hint

      t.timestamps
    end
    
    add_index :training_questions, [:training_module_id, :position]
  end
end

