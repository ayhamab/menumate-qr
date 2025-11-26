class CreateCorporateAccountUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :corporate_account_users do |t|
      t.references :corporate_account, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :role, default: 'member' # admin, manager, member
      t.boolean :active, default: true

      t.timestamps
    end
    
    add_index :corporate_account_users, [:corporate_account_id, :user_id], unique: true, name: 'index_corporate_account_users_unique'
    add_index :corporate_account_users, :role
  end
end
