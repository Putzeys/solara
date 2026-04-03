class DashboardController < ApplicationController
  before_action :auto_rollover, only: :show

  def show
    @tasks = current_user.tasks
      .for_date(current_date)
      .top_level
      .ordered
      .includes(:channel, :subtasks)

    @backlog_tasks = current_user.tasks
      .backlog
      .top_level
      .ordered
      .includes(:channel)
      .limit(10)

    @channels = current_user.channels.active.ordered.includes(:context)
    @contexts = current_user.contexts.active.ordered

    @working_sessions = current_user.working_sessions
      .for_date(current_date)
      .ordered
      .includes(:task)

    @calendar_events = current_user.calendar_events
      .for_date(current_date)
      .ordered

    @daily_plan = current_user.daily_plans.find_or_initialize_by(plan_date: current_date)
    @weekly_objectives = current_user.weekly_objectives.for_week(current_date).active.ordered

    @rolled_over_count = flash[:rolled_over_count]
  end

  private

  def auto_rollover
    return unless current_date == Date.current

    rolled = current_user.tasks
      .not_done
      .top_level
      .where("scheduled_date < ?", Date.current)
      .update_all(scheduled_date: Date.current, source: "rollover")

    if rolled > 0
      flash.now[:notice] = "#{rolled} #{"task".pluralize(rolled)} rolled over from previous days."
      flash[:rolled_over_count] = rolled
    end
  end
end
