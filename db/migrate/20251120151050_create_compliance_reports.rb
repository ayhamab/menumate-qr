class CreateComplianceReports < ActiveRecord::Migration[8.1]
  def change
    create_table :compliance_reports do |t|
      t.references :restaurant, null: false, foreign_key: true
      t.references :region, null: true, foreign_key: true
      
      t.string :report_type, null: false # full_compliance, regional_compliance, law_specific, menu_item_audit
      t.string :title, null: false
      t.text :summary
      t.text :findings # JSON
      t.text :recommendations # JSON
      t.text :violations_summary # JSON
      t.decimal :compliance_percentage, precision: 5, scale: 2
      t.boolean :shared_with_restaurant, default: false
      t.date :shared_at

      t.timestamps
    end

    add_index :compliance_reports, [:restaurant_id, :region_id]
    add_index :compliance_reports, :report_type
    add_index :compliance_reports, :compliance_percentage
  end
end

