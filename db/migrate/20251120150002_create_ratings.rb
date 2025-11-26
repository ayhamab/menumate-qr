class CreateRatings < ActiveRecord::Migration[8.1]
  def change
    create_table :ratings do |t|
      t.references :menu_item, null: false, foreign_key: true
      t.integer :rating, null: false
      t.text :comment
      t.string :ip_address
      t.string :user_agent

      t.timestamps
    end
    
    add_index :ratings, :rating
    add_index :ratings, :created_at
  end
end
