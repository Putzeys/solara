class AddCalendarMetadataToIntegrations < ActiveRecord::Migration[8.0]
  def change
    add_column :calendar_integrations, :calendar_metadata, :jsonb, default: {}
    add_column :calendar_integrations, :hidden_calendar_ids, :jsonb, default: []
  end
end
