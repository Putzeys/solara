class SettingsController < ApplicationController
  def show
    @user = current_user
  end

  def update
    if current_user.update(settings_params)
      redirect_to settings_path, notice: "Settings updated."
    else
      @user = current_user
      render :show, status: :unprocessable_entity
    end
  end

  private

  def settings_params
    params.require(:user).permit(:timezone, :daily_hour_target, :week_start_day, :pomodoro_work_min, :pomodoro_break_min)
  end
end
