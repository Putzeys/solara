class GoogleCalendarController < ApplicationController
  def authorize
    redirect_to root_path, alert: "Google Calendar integration not configured yet."
  end

  def callback
    redirect_to settings_path, notice: "Google Calendar connected."
  end

  def disconnect
    current_user.calendar_integrations.where(provider: "google").destroy_all
    redirect_to settings_path, notice: "Google Calendar disconnected."
  end

  def sync
    redirect_to settings_path, notice: "Sync triggered."
  end
end
