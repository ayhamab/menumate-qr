class CreateSeasonalMenuSchedules < ActiveRecord::Migration[8.1]
  def change
    create_table :seasonal_menu_schedules do |t|
      t.references :restaurant, null: false, foreign_key: true
      t.references :menu_item, null: false, foreign_key: true
      t.string :name, null: false
      t.date :start_date, null: false
      t.date :end_date, null: false
      t.time :start_time
      t.time :end_time
      t.boolean :active, default: true, null: false
      t.boolean :recurring, default: false, null: false
      t.string :recurring_pattern # yearly, monthly, weekly, daily

      t.timestamps
    end

    add_index :seasonal_menu_schedules, [:restaurant_id, :menu_item_id]
    add_index :seasonal_menu_schedules, :start_date
    add_index :seasonal_menu_schedules, :end_date
    add_index :seasonal_menu_schedules, :active
    add_index :seasonal_menu_schedules, [:start_date, :end_date, :active], name: 'index_seasonal_schedules_on_dates_and_active'
  end
end
