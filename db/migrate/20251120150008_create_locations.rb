class CreateLocations < ActiveRecord::Migration[8.1]
  def change
    create_table :locations do |t|
      t.references :restaurant, null: false, foreign_key: true
      t.string :name, null: false
      t.string :address, null: false
      t.string :phone_number
      t.string :email
      t.string :manager_name
      t.boolean :active, default: true
      t.decimal :latitude, precision: 10, scale: 7
      t.decimal :longitude, precision: 10, scale: 7
      t.text :notes
      t.string :timezone, default: 'UTC'

      t.timestamps
    end
    
    add_index :locations, :active
  end
end
