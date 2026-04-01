module Api
  module V1
    class WorkingSessionsController < BaseController
      def index
        sessions = current_user.working_sessions.ordered.includes(:task)
        sessions = sessions.for_date(Date.parse(params[:date])) if params[:date].present?
        render json: { data: sessions.as_json(include: { task: { only: [ :id, :title ] } }) }
      end

      def create
        session = current_user.working_sessions.build(params.permit(:task_id, :starts_at, :ends_at))
        if session.save
          render json: { data: session }, status: :created
        else
          render json: { error: { details: session.errors } }, status: :unprocessable_entity
        end
      end

      def update
        session = current_user.working_sessions.find(params[:id])
        session.update!(params.permit(:starts_at, :ends_at))
        render json: { data: session }
      end

      def destroy
        current_user.working_sessions.find(params[:id]).destroy
        head :no_content
      end
    end
  end
end
