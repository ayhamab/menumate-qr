class CreateQrCodes < ActiveRecord::Migration[8.1]
  def change
    create_table :qr_codes do |t|
      t.string :token, null: false
      t.references :restaurant, null: false, foreign_key: true

      t.timestamps
    end

    add_index :qr_codes, :token, unique: true
  end
end

