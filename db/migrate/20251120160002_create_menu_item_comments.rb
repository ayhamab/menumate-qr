class CreateMenuItemComments < ActiveRecord::Migration[8.1]
  def change
    create_table :menu_item_comments do |t|
      t.references :menu_item, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.references :parent, null: true, foreign_key: { to_table: :menu_item_comments }
      t.text :content, null: false

      t.timestamps
    end
    
    add_index :menu_item_comments, :menu_item_id unless index_exists?(:menu_item_comments, :menu_item_id)
    add_index :menu_item_comments, :user_id unless index_exists?(:menu_item_comments, :user_id)
    add_index :menu_item_comments, :parent_id unless index_exists?(:menu_item_comments, :parent_id)
  end
end

