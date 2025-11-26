class AddCuisineToRestaurants < ActiveRecord::Migration[8.1]
  def change
    add_column :restaurants, :cuisine, :string
    add_index :restaurants, :cuisine
  end
end

