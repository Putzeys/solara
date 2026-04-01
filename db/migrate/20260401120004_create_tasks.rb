class CreateTasks < ActiveRecord::Migration[8.0]
  def change
    create_table :tasks do |t|
      t.references :user, null: false, foreign_key: true
      t.references :channel, foreign_key: true
      t.references :weekly_objective, foreign_key: true
      t.bigint :parent_task_id
      t.string :title, null: false
      t.string :status, null: false, default: "todo"
      t.integer :priority, default: 0
      t.date :scheduled_date
      t.datetime :completed_at
      t.integer :planned_minutes
      t.integer :actual_minutes, default: 0
      t.integer :position, null: false, default: 0
      t.datetime :time_slot_start
      t.datetime :time_slot_end
      t.string :recurrence_rule
      t.bigint :recurrence_parent_id
      t.date :due_date
      t.date :snoozed_until
      t.string :source, default: "manual"
      t.string :external_id

      t.timestamps
    end

    add_foreign_key :tasks, :tasks, column: :parent_task_id
    add_foreign_key :tasks, :tasks, column: :recurrence_parent_id

    add_index :tasks, [:user_id, :scheduled_date, :position]
    add_index :tasks, [:user_id, :status]
    add_index :tasks, [:user_id, :channel_id]
    add_index :tasks, :parent_task_id
    add_index :tasks, :recurrence_parent_id
    # Partial index for backlog queries
    add_index :tasks, [:user_id], where: "scheduled_date IS NULL", name: "index_tasks_on_user_id_backlog"
  end
end
