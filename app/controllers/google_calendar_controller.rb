class GoogleCalendarController < ApplicationController
  def authorize
    unless GoogleCalendar::Client.configured?
      redirect_to settings_path, alert: "Google Calendar not configured. Set GOOGLE_CLIENT_ID and GOOGLE_CLIENT_SECRET."
      return
    end

    url = GoogleCalendar::Client.authorization_url(redirect_uri: callback_url)
    redirect_to url, allow_other_host: true
  end

  def callback
    client = GoogleCalendar::Client.exchange_code(
      code: params[:code],
      redirect_uri: callback_url
    )

    integration = current_user.calendar_integrations.find_or_initialize_by(provider: "google")
    attrs = {
      access_token: client.access_token,
      token_expires_at: Time.current + client.expires_in.to_i.seconds,
      active: true
    }
    attrs[:refresh_token] = client.refresh_token if client.refresh_token.present?

    if integration.new_record? && attrs[:refresh_token].blank?
      redirect_to settings_path, alert: "Google did not return a refresh token. Please revoke access at https://myaccount.google.com/permissions and try again."
      return
    end

    integration.update!(attrs)

    # Fetch available calendars and store their IDs
    gcal = GoogleCalendar::Client.new(integration)
    calendars = gcal.list_calendars
    integration.update!(calendar_ids: calendars.map { |c| c[:id] })

    redirect_to settings_path, notice: "Google Calendar connected! #{calendars.size} calendars synced."
  rescue => e
    redirect_to settings_path, alert: "Failed to connect: #{e.message}"
  end

  def disconnect
    current_user.calendar_integrations.where(provider: "google").destroy_all
    current_user.calendar_events.destroy_all
    redirect_to settings_path, notice: "Google Calendar disconnected."
  end

  def sync
    integration = current_user.calendar_integrations.find_by(provider: "google", active: true)
    unless integration
      redirect_to settings_path, alert: "No Google Calendar connected."
      return
    end

    gcal = GoogleCalendar::Client.new(integration)
    gcal.sync_events

    event_count = current_user.calendar_events.count
    redirect_to settings_path, notice: "Sync complete! #{event_count} events loaded."
  rescue => e
    redirect_to settings_path, alert: "Sync failed: #{e.message}"
  end

  private

  def callback_url
    url_for(action: :callback, only_path: false)
  end
end
