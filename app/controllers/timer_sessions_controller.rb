class TimerSessionsController < ApplicationController
  def start
    task = current_user.tasks.find(params[:task_id])
    current_user.timer_sessions.active.each(&:stop!)

    @timer = current_user.timer_sessions.create!(
      task: task,
      started_at: Time.current,
      timer_type: %w[stopwatch pomodoro].include?(params[:timer_type]) ? params[:timer_type] : "stopwatch"
    )

    redirect_back fallback_location: root_path
  end

  def stop
    @timer = current_user.timer_sessions.active.first
    @timer&.stop!
    redirect_back fallback_location: root_path
  end

  def current
    @timer = current_user.timer_sessions.active.first
    render partial: "layouts/timer_bar"
  end
end
