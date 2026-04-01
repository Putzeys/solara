class CreateDailyPlans < ActiveRecord::Migration[8.0]
  def change
    create_table :daily_plans do |t|
      t.references :user, null: false, foreign_key: true
      t.date :plan_date, null: false
      t.boolean :morning_completed, default: false
      t.boolean :shutdown_completed, default: false
      t.datetime :morning_completed_at
      t.datetime :shutdown_completed_at
      t.integer :total_planned_min, default: 0
      t.integer :total_actual_min, default: 0
      t.integer :tasks_completed, default: 0
      t.integer :tasks_rolled_over, default: 0

      t.timestamps
    end

    add_index :daily_plans, [:user_id, :plan_date], unique: true
  end
end
