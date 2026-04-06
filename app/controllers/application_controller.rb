class ApplicationController < ActionController::Base
  allow_browser versions: :modern
  before_action :authenticate_user!
  around_action :set_user_timezone, if: :user_signed_in?

  private

  def set_user_timezone(&block)
    Time.use_zone(current_user.timezone, &block)
  end

  def current_date
    @current_date ||= if params[:date].present?
      Date.parse(params[:date])
    else
      Date.current
    end
  rescue Date::Error
    Date.current
  end
  helper_method :current_date
end
