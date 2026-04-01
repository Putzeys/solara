class TasksController < ApplicationController
  before_action :set_task, only: [:show, :edit, :update, :destroy, :complete, :reopen, :schedule, :unschedule]

  def index
    @tasks = current_user.tasks.top_level.ordered.includes(:channel)
    @tasks = @tasks.for_date(params[:date]) if params[:date].present?
  end

  def show
    @subtasks = @task.subtasks.ordered
  end

  def new
    @task = current_user.tasks.build(scheduled_date: current_date)
    @channels = current_user.channels.active.ordered
  end

  def edit
    @channels = current_user.channels.active.ordered
  end

  def create
    @task = current_user.tasks.build(task_params)
    if @task.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_back fallback_location: root_path }
      end
    else
      @channels = current_user.channels.active.ordered
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @task.update(task_params)
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_back fallback_location: root_path }
      end
    else
      @channels = current_user.channels.active.ordered
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @task.destroy
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_back fallback_location: root_path }
    end
  end

  def complete
    @task.complete!
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_back fallback_location: root_path }
    end
  end

  def reopen
    @task.reopen!
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_back fallback_location: root_path }
    end
  end

  def schedule
    @task.update!(scheduled_date: params[:date])
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_back fallback_location: root_path }
    end
  end

  def unschedule
    @task.update!(scheduled_date: nil)
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_back fallback_location: root_path }
    end
  end

  def reorder
    Task.transaction do
      params[:task_ids].each_with_index do |id, index|
        current_user.tasks.where(id: id).update_all(position: index)
      end
    end
    head :ok
  end

  private

  def set_task
    @task = current_user.tasks.find(params[:id])
  end

  def task_params
    params.require(:task).permit(
      :title, :channel_id, :weekly_objective_id, :parent_task_id,
      :status, :priority, :scheduled_date, :planned_minutes,
      :due_date, :notes
    )
  end
end
