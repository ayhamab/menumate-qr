class CreateDietaryTrends < ActiveRecord::Migration[8.1]
  def change
    create_table :dietary_trends do |t|
      t.string :dietary_tag, null: false # vegan, vegetarian, gluten-free, etc.
      t.string :region # Optional: city, state, country
      t.decimal :trend_percentage, precision: 5, scale: 2, null: false # Percentage of items with this tag
      t.integer :sample_size, null: false # Number of menu items analyzed
      t.date :trend_date, null: false
      t.string :category # Optional: menu category filter
      t.decimal :growth_rate, precision: 5, scale: 2 # Month-over-month growth
      t.json :metadata # Additional trend data

      t.timestamps
    end
    
    add_index :dietary_trends, :dietary_tag
    add_index :dietary_trends, :trend_date
    add_index :dietary_trends, :region
    add_index :dietary_trends, [:dietary_tag, :trend_date, :region], name: 'index_dietary_trends_on_tag_date_region'
  end
end
