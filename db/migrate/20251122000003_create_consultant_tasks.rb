class CreateConsultantTasks < ActiveRecord::Migration[8.1]
  def change
    create_table :consultant_tasks do |t|
      t.references :consultant, null: false, foreign_key: true
      t.references :restaurant, null: true, foreign_key: true
      t.references :menu_item, null: true, foreign_key: true
      
      t.string :task_type, null: false # menu_review, pricing_analysis, dietary_compliance, menu_optimization, training, other
      t.string :title, null: false
      t.text :description
      t.string :status, default: 'pending' # pending, in_progress, completed, cancelled
      t.string :priority, default: 'medium' # low, medium, high, urgent
      t.date :due_date
      t.date :completed_at
      t.text :notes

      t.timestamps
    end

    add_index :consultant_tasks, [:consultant_id, :status]
    add_index :consultant_tasks, [:restaurant_id, :status]
    add_index :consultant_tasks, :priority
    add_index :consultant_tasks, :due_date
  end
end

