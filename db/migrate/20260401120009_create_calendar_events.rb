class CreateCalendarEvents < ActiveRecord::Migration[8.0]
  def change
    create_table :calendar_events do |t|
      t.references :user, null: false, foreign_key: true
      t.references :calendar_integration, null: false, foreign_key: true
      t.string :google_event_id, null: false
      t.string :google_calendar_id, null: false
      t.string :title, null: false
      t.text :description
      t.string :location
      t.datetime :starts_at, null: false
      t.datetime :ends_at, null: false
      t.boolean :all_day, default: false
      t.string :status, default: "confirmed"
      t.jsonb :attendees, default: []
      t.string :html_link
      t.boolean :recurring, default: false
      t.jsonb :raw_data

      t.timestamps
    end

    add_index :calendar_events, [ :user_id, :starts_at, :ends_at ]
    add_index :calendar_events, [ :google_event_id, :google_calendar_id ], unique: true, name: "idx_cal_events_google_unique"
  end
end
