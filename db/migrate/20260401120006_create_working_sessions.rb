class CreateWorkingSessions < ActiveRecord::Migration[8.0]
  def change
    create_table :working_sessions do |t|
      t.references :user, null: false, foreign_key: true
      t.references :task, null: false, foreign_key: true
      t.datetime :starts_at, null: false
      t.datetime :ends_at, null: false
      t.string :google_event_id

      t.timestamps
    end

    add_index :working_sessions, [ :user_id, :starts_at, :ends_at ]
  end
end
