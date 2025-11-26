class CreateMenuConsistencyReports < ActiveRecord::Migration[8.1]
  def change
    create_table :menu_consistency_reports do |t|
      t.references :corporate_account, null: false, foreign_key: true
      t.references :menu_template, null: true, foreign_key: true
      t.references :generated_by, null: true, foreign_key: { to_table: :users }
      
      t.string :report_type, null: false # full, location_comparison, item_analysis, override_summary
      t.text :report_data # JSON
      t.datetime :generated_at

      t.timestamps
    end

    add_index :menu_consistency_reports, [:corporate_account_id, :created_at]
    add_index :menu_consistency_reports, :report_type
  end
end

