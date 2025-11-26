class CreateConsultantReports < ActiveRecord::Migration[8.1]
  def change
    create_table :consultant_reports do |t|
      t.references :consultant, null: false, foreign_key: true
      t.references :restaurant, null: false, foreign_key: true
      
      t.string :report_type, null: false # menu_analysis, performance_review, dietary_compliance, pricing_analysis, recommendations
      t.string :title, null: false
      t.text :content, null: false
      t.text :findings # JSON
      t.text :recommendations # JSON
      t.boolean :shared_with_restaurant, default: false
      t.date :shared_at

      t.timestamps
    end

    add_index :consultant_reports, [:consultant_id, :restaurant_id]
    add_index :consultant_reports, :report_type
    add_index :consultant_reports, :shared_with_restaurant
  end
end

