class CreateSupplierContacts < ActiveRecord::Migration[8.1]
  def change
    create_table :supplier_contacts do |t|
      t.references :supplier, null: false, foreign_key: true
      t.references :restaurant, null: true, foreign_key: true
      t.references :ingredient_listing, null: true, foreign_key: true
      t.string :contact_type, null: false # inquiry, quote_request, order, general
      t.string :name, null: false
      t.string :email, null: false
      t.string :phone_number
      t.text :message, null: false
      t.boolean :read, default: false
      t.datetime :read_at

      t.timestamps
    end

    add_index :supplier_contacts, [:supplier_id, :read]
    add_index :supplier_contacts, :contact_type
  end
end

