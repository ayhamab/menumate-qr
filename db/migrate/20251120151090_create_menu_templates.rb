class CreateMenuTemplates < ActiveRecord::Migration[8.1]
  def change
    create_table :menu_templates do |t|
      t.references :corporate_account, null: false, foreign_key: true
      t.string :name, null: false
      t.string :version, null: false
      t.string :status, default: 'draft' # draft, active, archived
      t.text :description
      t.text :settings # JSON
      t.date :effective_date
      t.date :expiry_date

      t.timestamps
    end

    add_index :menu_templates, [:corporate_account_id, :version]
    add_index :menu_templates, :status
  end
end

