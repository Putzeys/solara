class ApplicationController < ActionController::Base
  allow_browser versions: :modern
  before_action :authenticate_user!

  private

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
