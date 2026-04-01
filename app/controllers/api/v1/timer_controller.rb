module Api
  module V1
    class TimerController < BaseController
      def start
        task = current_user.tasks.find(params[:task_id])
        current_user.timer_sessions.active.each(&:stop!)
        timer = current_user.timer_sessions.create!(
          task: task,
          started_at: Time.current,
          timer_type: %w[stopwatch pomodoro].include?(params[:timer_type]) ? params[:timer_type] : "stopwatch"
        )
        render json: { data: timer.as_json(include: { task: { only: [:id, :title] } }) }, status: :created
      end

      def stop
        timer = current_user.timer_sessions.active.first
        if timer
          timer.stop!
          render json: { data: timer }
        else
          render json: { error: { code: "no_active_timer" } }, status: :not_found
        end
      end

      def current
        timer = current_user.timer_sessions.active.first
        if timer
          render json: { data: timer.as_json(methods: :elapsed_seconds, include: { task: { only: [:id, :title] } }) }
        else
          render json: { data: nil }
        end
      end
    end
  end
end
