class CreateQrScans < ActiveRecord::Migration[8.1]
  def change
    create_table :qr_scans do |t|
      t.references :restaurant, null: false, foreign_key: true, index: true
      t.datetime :scanned_at, null: false
      t.string :ip_address
      t.string :user_agent

      t.timestamps
    end

    add_index :qr_scans, :scanned_at
  end
end

