class CreateRestaurantTeams < ActiveRecord::Migration[8.1]
  def change
    create_table :restaurant_teams do |t|
      t.references :restaurant, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :role, default: 'staff' # owner, chef, manager, staff
      t.boolean :active, default: true

      t.timestamps
    end
    
    add_index :restaurant_teams, [:restaurant_id, :user_id], unique: true, name: 'index_restaurant_teams_unique'
    add_index :restaurant_teams, :role
    add_index :restaurant_teams, :active
  end
end

