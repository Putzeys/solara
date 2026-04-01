module Api
  module V1
    class DailyPlansController < BaseController
      def show
        date = Date.parse(params[:date])
        plan = current_user.daily_plans.find_or_initialize_by(plan_date: date)
        tasks = current_user.tasks.for_date(date).top_level.ordered.includes(:channel)
        render json: {
          data: {
            plan: plan,
            tasks: tasks.as_json(include: :channel),
            stats: {
              total_planned_min: tasks.sum(:planned_minutes),
              total_actual_min: tasks.sum(:actual_minutes),
              completed: tasks.done.count,
              remaining: tasks.not_done.count
            }
          }
        }
      end

      def rollover
        date = Date.parse(params[:date])
        next_date = date + 1
        count = current_user.tasks.for_date(date).not_done.update_all(scheduled_date: next_date, source: "rollover")
        render json: { data: { rolled_over: count, to_date: next_date } }
      end
    end
  end
end
