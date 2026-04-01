module Api
  module V1
    class BaseController < ActionController::API
      before_action :authenticate_api_token!

      rescue_from ActiveRecord::RecordNotFound do
        render json: { error: { code: "not_found" } }, status: :not_found
      end

      rescue_from ActiveRecord::RecordInvalid do |e|
        render json: { error: { code: "validation_error", details: e.record.errors } }, status: :unprocessable_entity
      end

      private

      def authenticate_api_token!
        token = request.headers["Authorization"]&.remove("Bearer ")
        return render json: { error: { code: "unauthorized" } }, status: :unauthorized if token.blank?

        @current_user = User.find_by(api_token: token)
        return render json: { error: { code: "unauthorized" } }, status: :unauthorized unless @current_user

        unless ActiveSupport::SecurityUtils.secure_compare(@current_user.api_token, token)
          render json: { error: { code: "unauthorized" } }, status: :unauthorized
        end
      end

      def current_user
        @current_user
      end
    end
  end
end
