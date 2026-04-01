module Api
  module V1
    class CalendarEventsController < BaseController
      def index
        events = current_user.calendar_events.ordered
        if params[:start_date].present? && params[:end_date].present?
          start_date = Date.parse(params[:start_date])
          end_date = Date.parse(params[:end_date])
          events = events.where("starts_at < ? AND ends_at > ?", end_date.end_of_day, start_date.beginning_of_day)
        end
        render json: { data: events }
      end
    end
  end
end
