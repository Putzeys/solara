class DailyPlansController < ApplicationController
  before_action :set_date

  def morning
    @daily_plan = current_user.daily_plans.find_or_initialize_by(plan_date: @date)
    @yesterday_tasks = current_user.tasks.for_date(@date - 1).top_level.ordered
    @backlog_tasks = current_user.tasks.backlog.top_level.ordered.limit(20)
  end

  def complete_morning
    @daily_plan = current_user.daily_plans.find_or_initialize_by(plan_date: @date)
    @daily_plan.update!(morning_completed: true, morning_completed_at: Time.current)
    redirect_to day_path(date: @date), notice: "Morning planning complete!"
  end

  def shutdown
    @daily_plan = current_user.daily_plans.find_or_initialize_by(plan_date: @date)
    @tasks = current_user.tasks.for_date(@date).top_level.ordered
  end

  def complete_shutdown
    @daily_plan = current_user.daily_plans.find_or_initialize_by(plan_date: @date)
    @daily_plan.update!(shutdown_completed: true, shutdown_completed_at: Time.current)
    redirect_to day_path(date: @date), notice: "Daily shutdown complete!"
  end

  def rollover
    next_date = @date + 1
    current_user.tasks.for_date(@date).not_done.update_all(scheduled_date: next_date, source: "rollover")
    redirect_to day_path(date: next_date), notice: "Tasks rolled over to #{next_date.strftime('%b %-d')}."
  end

  private

  def set_date
    @date = Date.parse(params[:date])
  rescue Date::Error
    redirect_to root_path, alert: "Invalid date."
  end
end
