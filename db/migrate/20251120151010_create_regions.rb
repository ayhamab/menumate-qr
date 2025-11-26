class CreateRegions < ActiveRecord::Migration[8.1]
  def change
    create_table :regions do |t|
      t.string :name, null: false
      t.string :code, null: false # ISO code or custom code
      t.string :country_code, null: false, limit: 2 # ISO 3166-1 alpha-2
      t.string :region_type, null: false # country, state, province, city, other
      t.string :parent_region_code # For hierarchical regions
      t.text :description
      t.boolean :active, default: true
      t.text :compliance_notes

      t.timestamps
    end

    add_index :regions, :code, unique: true
    add_index :regions, :name, unique: true
    add_index :regions, :country_code
    add_index :regions, :region_type
    add_index :regions, :active
  end
end

