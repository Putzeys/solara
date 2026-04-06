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

    google_email = GoogleCalendar::Client.fetch_user_email(client.access_token)

    integration = current_user.calendar_integrations.find_or_initialize_by(
      provider: "google",
      google_email: google_email
    )

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

    # Fetch available calendars and store their IDs + metadata
    gcal = GoogleCalendar::Client.new(integration)
    calendars = gcal.list_calendars
    metadata = calendars.each_with_object({}) { |c, h| h[c[:id]] = { summary: c[:summary], color: c[:color], primary: c[:primary] } }
    integration.update!(calendar_ids: calendars.map { |c| c[:id] }, calendar_metadata: metadata)

    redirect_to settings_path, notice: "#{google_email} connected! #{calendars.size} calendars synced."
  rescue => e
    redirect_to settings_path, alert: "Failed to connect: #{e.message}"
  end

  def toggle_calendar
    integration = current_user.calendar_integrations.find(params[:id])
    calendar_id = params[:calendar_id]
    hidden = (integration.hidden_calendar_ids || []).dup

    if hidden.include?(calendar_id)
      hidden.delete(calendar_id)
    else
      hidden << calendar_id
    end

    integration.update!(hidden_calendar_ids: hidden)
    redirect_back fallback_location: root_path
  end

  def disconnect
    integration = current_user.calendar_integrations.find(params[:id])
    integration.calendar_events.destroy_all
    integration.destroy!
    redirect_to settings_path, notice: "#{integration.google_email} disconnected."
  end

  def sync
    integration = current_user.calendar_integrations.find(params[:id])
    gcal = GoogleCalendar::Client.new(integration)
    gcal.sync_events

    redirect_to settings_path, notice: "#{integration.google_email} synced!"
  rescue => e
    redirect_to settings_path, alert: "Sync failed: #{e.message}"
  end

  private

  def callback_url
    url_for(action: :callback, only_path: false)
  end
end
