class CreateTrainingAnswers < ActiveRecord::Migration[8.1]
  def change
    create_table :training_answers do |t|
      t.references :training_session, null: false, foreign_key: true
      t.references :training_question, null: false, foreign_key: true
      t.json :selected_option # Selected answer(s)
      t.boolean :is_correct

      t.timestamps
    end
    
    add_index :training_answers, [:training_session_id, :training_question_id], unique: true
  end
end

