class AddCorporateAccountToRestaurants < ActiveRecord::Migration[8.1]
  def change
    add_reference :restaurants, :corporate_account, null: true, foreign_key: true
  end
end
