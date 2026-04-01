module Api
  module V1
    class ChannelsController < BaseController
      def index
        render json: { data: current_user.channels.active.ordered.as_json(include: :context) }
      end

      def show
        channel = current_user.channels.find(params[:id])
        render json: { data: channel.as_json(methods: [], include: { tasks: { only: [:id, :title, :status, :scheduled_date] } }) }
      end

      def create
        channel = current_user.channels.build(params.permit(:name, :color, :icon, :context_id))
        if channel.save
          render json: { data: channel }, status: :created
        else
          render json: { error: { code: "validation_error", details: channel.errors } }, status: :unprocessable_entity
        end
      end

      def update
        channel = current_user.channels.find(params[:id])
        if channel.update(params.permit(:name, :color, :icon, :context_id))
          render json: { data: channel }
        else
          render json: { error: { code: "validation_error", details: channel.errors } }, status: :unprocessable_entity
        end
      end

      def destroy
        current_user.channels.find(params[:id]).update(archived: true)
        head :no_content
      end
    end
  end
end
