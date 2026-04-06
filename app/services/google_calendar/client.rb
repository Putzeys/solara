module GoogleCalendar
  class Client
    SCOPES = [ "https://www.googleapis.com/auth/calendar.readonly" ].freeze

    def self.configured?
      ENV["GOOGLE_CLIENT_ID"].present? && ENV["GOOGLE_CLIENT_SECRET"].present?
    end

    def self.client_id
      ENV.fetch("GOOGLE_CLIENT_ID")
    end

    def self.client_secret
      ENV.fetch("GOOGLE_CLIENT_SECRET")
    end

    def self.authorization_url(redirect_uri:)
      client = Signet::OAuth2::Client.new(
        authorization_uri: "https://accounts.google.com/o/oauth2/auth",
        client_id: client_id,
        redirect_uri: redirect_uri,
        scope: SCOPES.join(" "),
        access_type: "offline",
        additional_parameters: { prompt: "consent" }
      )
      client.authorization_uri.to_s
    end

    def self.exchange_code(code:, redirect_uri:)
      client = Signet::OAuth2::Client.new(
        token_credential_uri: "https://oauth2.googleapis.com/token",
        client_id: client_id,
        client_secret: client_secret,
        code: code,
        redirect_uri: redirect_uri,
        grant_type: "authorization_code"
      )
      client.fetch_access_token!
      client
    end

    def initialize(integration)
      @integration = integration
    end

    def calendar_service
      refresh_token_if_needed!

      service = Google::Apis::CalendarV3::CalendarService.new
      service.authorization = signet_client
      service
    end

    def list_calendars
      calendar_service.list_calendar_lists.items.map do |cal|
        { id: cal.id, summary: cal.summary, primary: cal.primary, color: cal.background_color }
      end
    end

    def sync_events
      @integration.calendar_ids.each do |calendar_id|
        sync_calendar(calendar_id)
      end
      @integration.update!(last_synced_at: Time.current)
    end

    private

    def sync_calendar(calendar_id)
      service = calendar_service
      params = {
        single_events: true,
        order_by: "startTime",
        time_min: 30.days.ago.iso8601,
        time_max: 30.days.from_now.iso8601
      }
      params[:sync_token] = @integration.sync_token if @integration.sync_token.present?

      begin
        result = if @integration.sync_token.present?
          service.list_events(calendar_id, sync_token: @integration.sync_token)
        else
          service.list_events(calendar_id, **params)
        end

        result.items&.each do |event|
          process_event(event, calendar_id)
        end

        @integration.update!(sync_token: result.next_sync_token) if result.next_sync_token
      rescue Google::Apis::ClientError => e
        if e.message.include?("Sync token")
          @integration.update!(sync_token: nil)
          sync_calendar(calendar_id)
        else
          raise
        end
      end
    end

    def process_event(event, calendar_id)
      return if event.start.nil?

      starts_at = event.start.date_time || event.start.date&.to_datetime
      ends_at = event.end&.date_time || event.end&.date&.to_datetime
      return unless starts_at && ends_at

      if event.status == "cancelled"
        @integration.calendar_events
          .where(google_event_id: event.id, google_calendar_id: calendar_id)
          .destroy_all
        return
      end

      cal_event = @integration.calendar_events
        .find_or_initialize_by(google_event_id: event.id, google_calendar_id: calendar_id)

      cal_event.assign_attributes(
        user: @integration.user,
        title: event.summary || "(No title)",
        description: event.description,
        location: event.location,
        starts_at: starts_at,
        ends_at: ends_at,
        all_day: event.start.date.present?,
        status: event.status || "confirmed",
        attendees: (event.attendees || []).map { |a| { email: a.email, name: a.display_name, response: a.response_status } },
        html_link: event.html_link,
        recurring: event.recurring_event_id.present?,
        raw_data: event.to_h
      )
      cal_event.save!
    end

    def signet_client
      @signet_client ||= Signet::OAuth2::Client.new(
        client_id: self.class.client_id,
        client_secret: self.class.client_secret,
        token_credential_uri: "https://oauth2.googleapis.com/token",
        access_token: @integration.access_token,
        refresh_token: @integration.refresh_token,
        expires_at: @integration.token_expires_at
      )
    end

    def refresh_token_if_needed!
      return unless @integration.token_expired?

      signet_client.refresh!
      @integration.update!(
        access_token: signet_client.access_token,
        token_expires_at: Time.current + signet_client.expires_in.to_i.seconds
      )
    end
  end
end
