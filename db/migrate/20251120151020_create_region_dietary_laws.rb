class CreateRegionDietaryLaws < ActiveRecord::Migration[8.1]
  def change
    create_table :region_dietary_laws do |t|
      t.references :region, null: false, foreign_key: true
      t.references :dietary_law, null: false, foreign_key: true
      t.string :enforcement_level, default: 'mandatory' # mandatory, recommended, optional
      t.date :effective_date
      t.date :expiry_date
      t.text :notes

      t.timestamps
    end

    add_index :region_dietary_laws, [:region_id, :dietary_law_id], unique: true
    add_index :region_dietary_laws, :enforcement_level
  end
end

