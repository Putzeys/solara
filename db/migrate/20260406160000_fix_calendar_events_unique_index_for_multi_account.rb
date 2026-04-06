class FixCalendarEventsUniqueIndexForMultiAccount < ActiveRecord::Migration[8.0]
  def change
    remove_index :calendar_events, name: "idx_cal_events_google_unique"
    add_index :calendar_events, [ :calendar_integration_id, :google_event_id, :google_calendar_id ],
              unique: true, name: "idx_cal_events_google_unique"
  end
end
