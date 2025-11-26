class CreateDietaryFeedbacks < ActiveRecord::Migration[8.1]
  def change
    create_table :dietary_feedbacks do |t|
      t.references :menu_item, null: false, foreign_key: true
      t.references :restaurant, null: false, foreign_key: true
      t.references :user, null: true, foreign_key: true
      t.references :resolved_by, null: true, foreign_key: { to_table: :users }
      
      t.string :feedback_type, null: false # incorrect_tag, missing_tag, allergen_issue, description_issue, other
      t.string :severity, default: 'medium' # low, medium, high, critical
      t.text :message, null: false
      t.text :reported_tags # JSON array
      t.text :suggested_tags # JSON array
      t.boolean :resolved, default: false
      t.datetime :resolved_at
      t.text :resolution_notes
      t.string :contact_email
      t.string :contact_phone

      t.timestamps
    end

    add_index :dietary_feedbacks, [:menu_item_id, :created_at]
    add_index :dietary_feedbacks, [:restaurant_id, :resolved]
    add_index :dietary_feedbacks, :feedback_type
    add_index :dietary_feedbacks, :severity
    add_index :dietary_feedbacks, :resolved
  end
end

