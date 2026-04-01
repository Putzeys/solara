module Api
  module V1
    class SearchController < BaseController
      def index
        query = params[:q].to_s.strip
        return render json: { data: [] } if query.blank?

        sanitized = ActiveRecord::Base.sanitize_sql_like(query)
        tasks = current_user.tasks.where("title ILIKE ?", "%#{sanitized}%").limit(50)
        render json: { data: tasks.as_json(include: :channel) }
      end
    end
  end
end
