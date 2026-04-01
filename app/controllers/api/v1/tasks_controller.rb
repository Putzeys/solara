module Api
  module V1
    class TasksController < BaseController
      before_action :set_task, only: [:show, :update, :destroy, :complete, :reopen, :schedule, :unschedule]

      def index
        tasks = current_user.tasks.top_level.ordered.includes(:channel)
        tasks = tasks.for_date(params[:date]) if params[:date].present?
        tasks = tasks.where(channel_id: params[:channel_id]) if params[:channel_id].present?
        tasks = tasks.where(status: params[:status]) if params[:status].present?
        render json: { data: tasks.as_json(include: :channel) }
      end

      def today
        tasks = current_user.tasks.for_date(Date.current).top_level.ordered.includes(:channel)
        render json: { data: tasks.as_json(include: :channel) }
      end

      def backlog
        tasks = current_user.tasks.backlog.top_level.ordered.includes(:channel)
        render json: { data: tasks.as_json(include: :channel) }
      end

      def show
        render json: { data: @task.as_json(include: [:channel, :subtasks]) }
      end

      def create
        task = current_user.tasks.build(task_params)
        if task.save
          render json: { data: task }, status: :created
        else
          render json: { error: { code: "validation_error", details: task.errors } }, status: :unprocessable_entity
        end
      end

      def update
        if @task.update(task_params)
          render json: { data: @task }
        else
          render json: { error: { code: "validation_error", details: @task.errors } }, status: :unprocessable_entity
        end
      end

      def destroy
        @task.destroy
        head :no_content
      end

      def complete
        @task.complete!
        render json: { data: @task }
      end

      def reopen
        @task.reopen!
        render json: { data: @task }
      end

      def schedule
        @task.update!(scheduled_date: params[:date])
        render json: { data: @task }
      end

      def unschedule
        @task.update!(scheduled_date: nil)
        render json: { data: @task }
      end

      private

      def set_task
        @task = current_user.tasks.find(params[:id])
      end

      def task_params
        params.permit(:title, :channel_id, :weekly_objective_id, :parent_task_id,
                       :status, :priority, :scheduled_date, :planned_minutes, :due_date)
      end
    end
  end
end
