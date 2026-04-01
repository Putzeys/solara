class WorkingSessionsController < ApplicationController
  def create
    @session = current_user.working_sessions.build(session_params)
    if @session.save
      redirect_back fallback_location: root_path
    else
      redirect_back fallback_location: root_path, alert: "Failed to create working session."
    end
  end

  def update
    @session = current_user.working_sessions.find(params[:id])
    @session.update(session_params)
    redirect_back fallback_location: root_path
  end

  def destroy
    current_user.working_sessions.find(params[:id]).destroy
    redirect_back fallback_location: root_path
  end

  private

  def session_params
    params.require(:working_session).permit(:task_id, :starts_at, :ends_at)
  end
end
