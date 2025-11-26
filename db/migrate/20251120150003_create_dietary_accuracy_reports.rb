class CreateDietaryAccuracyReports < ActiveRecord::Migration[8.1]
  def change
    create_table :dietary_accuracy_reports do |t|
      t.references :menu_item, null: false, foreign_key: true
      t.string :issue_type, null: false # 'missing_allergen', 'incorrect_allergen', 'missing_dietary_tag', 'incorrect_dietary_tag'
      t.text :description, null: false
      t.string :reported_by # Optional name/email
      t.string :ip_address
      t.string :user_agent
      t.boolean :resolved, default: false
      t.text :resolution_notes # For restaurant owners to respond

      t.timestamps
    end
    
    add_index :dietary_accuracy_reports, :issue_type
    add_index :dietary_accuracy_reports, :resolved
    add_index :dietary_accuracy_reports, :created_at
  end
end
