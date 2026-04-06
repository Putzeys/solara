class AddGoogleEmailToCalendarIntegrations < ActiveRecord::Migration[8.0]
  def up
    add_column :calendar_integrations, :google_email, :string
    change_column_null :calendar_integrations, :refresh_token, true

    # Clear existing integrations so user re-connects with email tracked
    execute "DELETE FROM calendar_events"
    execute "DELETE FROM calendar_integrations"

    remove_index :calendar_integrations, [ :user_id, :provider ]
    add_index :calendar_integrations, [ :user_id, :provider, :google_email ], unique: true
  end

  def down
    remove_index :calendar_integrations, [ :user_id, :provider, :google_email ]
    add_index :calendar_integrations, [ :user_id, :provider ], unique: true
    change_column_null :calendar_integrations, :refresh_token, false
    remove_column :calendar_integrations, :google_email
  end
end
