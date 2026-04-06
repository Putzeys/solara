class CalendarSyncJob < ApplicationJob
  queue_as :default

  SYNC_INTERVAL = 15.minutes

  def perform
    CalendarIntegration.active.find_each do |integration|
      sync_integration(integration)
    end
  ensure
    self.class.set(wait: SYNC_INTERVAL).perform_later
  end

  private

  def sync_integration(integration)
    client = GoogleCalendar::Client.new(integration)
    client.sync_events
    Rails.logger.info "[CalendarSync] Synced #{integration.google_email} (user #{integration.user_id})"
  rescue => e
    Rails.logger.error "[CalendarSync] Failed for integration #{integration.id}: #{e.message}"
  end
end
