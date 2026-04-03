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
    @tasks = current_user.tasks.for_date(@date).top_level.ordered.includes(:channel)
    @completed = @tasks.done
    @incomplete = @tasks.not_done
  end

  def complete_shutdown
    tasks = current_user.tasks.for_date(@date).top_level.ordered.includes(:channel)
    completed = tasks.done
    incomplete = tasks.not_done

    # Save snapshot
    @daily_plan = current_user.daily_plans.find_or_initialize_by(plan_date: @date)
    @daily_plan.update!(
      shutdown_completed: true,
      shutdown_completed_at: Time.current,
      total_planned_min: tasks.sum(:planned_minutes),
      total_actual_min: tasks.sum(:actual_minutes),
      tasks_completed: completed.count,
      tasks_rolled_over: incomplete.count,
      completed_snapshot: completed.map { |t| { id: t.id, title: t.title, channel: t.channel&.name, planned_minutes: t.planned_minutes, actual_minutes: t.actual_minutes } },
      rolled_snapshot: incomplete.map { |t| { id: t.id, title: t.title, channel: t.channel&.name, rollover_count: t.rollover_count + 1 } }
    )

    # Auto-rollover incomplete to next day
    incomplete.each do |task|
      task.increment!(:rollover_count)
    end
    incomplete.update_all(scheduled_date: @date + 1, source: "rollover")

    redirect_to day_path(date: @date), notice: "Shutdown complete. #{incomplete.count} tasks moved to tomorrow."
  end

  def rollover
    next_date = @date + 1
    tasks = current_user.tasks.for_date(@date).not_done
    tasks.each { |t| t.increment!(:rollover_count) }
    tasks.update_all(scheduled_date: next_date, source: "rollover")
    redirect_to day_path(date: next_date), notice: "Tasks rolled over to #{next_date.strftime('%b %-d')}."
  end

  private

  def set_date
    @date = Date.parse(params[:date])
  rescue Date::Error
    redirect_to root_path, alert: "Invalid date."
  end
end
