class CreateSubscriptions < ActiveRecord::Migration[8.1]
  def change
    create_table :subscriptions do |t|
      t.references :restaurant, null: false, foreign_key: true
      t.string :stripe_subscription_id
      t.string :stripe_customer_id
      t.string :plan_name, null: false, default: 'basic'
      t.string :status, null: false, default: 'incomplete'
      t.datetime :current_period_start
      t.datetime :current_period_end
      t.boolean :cancel_at_period_end, default: false
      t.string :stripe_price_id

      t.timestamps
    end
    
    add_index :subscriptions, :stripe_subscription_id, unique: true
    add_index :subscriptions, :stripe_customer_id
    add_index :subscriptions, :status
    add_index :subscriptions, :plan_name
  end
end
