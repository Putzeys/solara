module Api
  module V1
    class WeeklyObjectivesController < BaseController
      def index
        objectives = current_user.weekly_objectives.ordered
        objectives = objectives.for_week(Date.parse(params[:week_of])) if params[:week_of].present?
        render json: { data: objectives }
      end

      def create
        obj = current_user.weekly_objectives.build(params.permit(:title, :week_start_date, :status))
        if obj.save
          render json: { data: obj }, status: :created
        else
          render json: { error: { details: obj.errors } }, status: :unprocessable_entity
        end
      end

      def update
        obj = current_user.weekly_objectives.find(params[:id])
        obj.update!(params.permit(:title, :status))
        render json: { data: obj }
      end

      def destroy
        current_user.weekly_objectives.find(params[:id]).destroy
        head :no_content
      end
    end
  end
end
