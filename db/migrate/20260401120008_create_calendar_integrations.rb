class CreateCalendarIntegrations < ActiveRecord::Migration[8.0]
  def change
    create_table :calendar_integrations do |t|
      t.references :user, null: false, foreign_key: true
      t.string :provider, null: false, default: "google"
      t.text :access_token, null: false
      t.text :refresh_token, null: false
      t.datetime :token_expires_at
      t.jsonb :calendar_ids, default: []
      t.string :sync_token
      t.datetime :last_synced_at
      t.boolean :active, default: true

      t.timestamps
    end

    add_index :calendar_integrations, [ :user_id, :provider ], unique: true
  end
end
