class AddBrandToQrCodes < ActiveRecord::Migration[8.1]
  def change
    add_reference :qr_codes, :brand, null: true, foreign_key: true
  end
end
