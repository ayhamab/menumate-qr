class CreateMenuPredictions < ActiveRecord::Migration[8.1]
  def change
    create_table :menu_predictions do |t|
      t.references :menu_item, null: false, foreign_key: true
      t.references :restaurant, null: false, foreign_key: true
      t.references :demographic_data, null: true, foreign_key: true
      
      t.string :prediction_type, null: false # success_score, popularity_score, revenue_potential, dietary_fit
      t.decimal :predicted_value, precision: 10, scale: 4
      t.decimal :confidence_score, precision: 5, scale: 4
      t.text :features # JSON
      t.text :prediction_details # JSON
      t.string :model_version
      t.boolean :actualized, default: false
      t.decimal :actual_value, precision: 10, scale: 4

      t.timestamps
    end

    add_index :menu_predictions, [:menu_item_id, :prediction_type, :created_at]
    add_index :menu_predictions, [:restaurant_id, :prediction_type]
    add_index :menu_predictions, :confidence_score
    add_index :menu_predictions, :actualized
  end
end

