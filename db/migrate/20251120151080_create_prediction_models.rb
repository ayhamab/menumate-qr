class CreatePredictionModels < ActiveRecord::Migration[8.1]
  def change
    create_table :prediction_models do |t|
      t.string :name, null: false
      t.string :model_type, null: false # linear_regression, random_forest, neural_network, gradient_boosting, ensemble
      t.string :version, null: false
      t.text :description
      t.text :model_parameters # JSON
      t.text :training_metrics # JSON: {accuracy: 0.85, r2_score: 0.82, ...}
      t.text :feature_importance # JSON: {"price": 0.25, "age": 0.15, ...}
      t.integer :training_samples
      t.date :trained_at
      t.boolean :active, default: false
      t.text :model_file_path # Path to serialized model file

      t.timestamps
    end

    add_index :prediction_models, [:name, :version], unique: true
    add_index :prediction_models, :active
    add_index :prediction_models, :model_type
  end
end

