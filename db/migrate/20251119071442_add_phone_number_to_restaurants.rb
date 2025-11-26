class AddPhoneNumberToRestaurants < ActiveRecord::Migration[8.1]
  def change
    add_column :restaurants, :phone_number, :string
  end
end
