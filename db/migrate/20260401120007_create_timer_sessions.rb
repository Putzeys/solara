class CreateTimerSessions < ActiveRecord::Migration[8.0]
  def change
    create_table :timer_sessions do |t|
      t.references :user, null: false, foreign_key: true
      t.references :task, null: false, foreign_key: true
      t.datetime :started_at, null: false
      t.datetime :ended_at
      t.integer :duration_seconds
      t.string :timer_type, default: "stopwatch"

      t.timestamps
    end

    add_index :timer_sessions, [ :user_id, :started_at ]
  end
end
