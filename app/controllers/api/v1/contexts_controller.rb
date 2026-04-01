module Api
  module V1
    class ContextsController < BaseController
      def index
        render json: { data: current_user.contexts.active.ordered.as_json(include: :channels) }
      end

      def create
        context = current_user.contexts.build(params.permit(:name, :color, :icon))
        if context.save
          render json: { data: context }, status: :created
        else
          render json: { error: { details: context.errors } }, status: :unprocessable_entity
        end
      end

      def update
        context = current_user.contexts.find(params[:id])
        context.update!(params.permit(:name, :color, :icon))
        render json: { data: context }
      end

      def destroy
        current_user.contexts.find(params[:id]).update(archived: true)
        head :no_content
      end
    end
  end
end
