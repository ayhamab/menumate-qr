class CreateDemographicData < ActiveRecord::Migration[8.1]
  def change
    create_table :demographic_data do |t|
      t.references :restaurant, null: true, foreign_key: true
      t.references :location, null: true, foreign_key: true
      t.string :region_code, null: false
      t.string :data_source, null: false # census_api, manual_entry, third_party_api, estimated
      t.text :age_distribution # JSON: {"18-24": 15, "25-34": 25, ...}
      t.text :income_distribution # JSON: {"$0-$25k": 20, "$25k-$50k": 30, ...}
      t.text :cultural_preferences # JSON: {"hispanic": 25, "asian": 15, ...}
      t.text :dietary_preferences # JSON: {"vegan": 10, "vegetarian": 15, "gluten-free": 8, ...}
      t.text :dining_preferences # JSON: {"fast_casual": 40, "fine_dining": 10, ...}
      t.boolean :verified, default: false
      t.date :data_date
      t.text :notes

      t.timestamps
    end

    add_index :demographic_data, :region_code
    add_index :demographic_data, :data_source
    add_index :demographic_data, :verified
  end
end

