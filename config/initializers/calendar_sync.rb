Rails.application.config.after_initialize do
  if defined?(Rails::Server) && GoogleCalendar::Client.configured?
    CalendarSyncJob.set(wait: 1.minute).perform_later
    Rails.logger.info "[CalendarSync] Auto-sync scheduled (every #{CalendarSyncJob::SYNC_INTERVAL / 60} min)"
  end
end
