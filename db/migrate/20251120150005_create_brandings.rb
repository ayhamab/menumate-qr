class CreateBrandings < ActiveRecord::Migration[8.1]
  def change
    create_table :brandings do |t|
      t.references :restaurant, null: false, foreign_key: true
      t.string :primary_color, default: '#4F46E5' # indigo-600
      t.string :secondary_color, default: '#7C3AED' # purple-600
      t.string :accent_color, default: '#EC4899' # pink-500
      t.string :font_family, default: 'Inter, system-ui, sans-serif'
      t.text :custom_css
      t.string :company_name # Override restaurant name in branding
      t.string :tagline
      t.boolean :hide_menumate_branding, default: false
      t.string :custom_domain # For white-label domains

      t.timestamps
    end
  end
end
