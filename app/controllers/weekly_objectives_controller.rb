class WeeklyObjectivesController < ApplicationController
  before_action :set_objective, only: [ :show, :edit, :update, :destroy ]

  def index
    @date = current_date
    @objectives = current_user.weekly_objectives.for_week(@date).ordered.includes(tasks: :channel)
  end

  def show
    @tasks = @objective.tasks.where(discarded_at: nil).ordered.includes(:channel)
    @available_tasks = current_user.tasks
      .where(discarded_at: nil, weekly_objective_id: nil)
      .not_done
      .top_level
      .ordered
      .includes(:channel)
      .limit(20)
  end

  def new
    @objective = current_user.weekly_objectives.build(week_start_date: current_date.beginning_of_week(:monday))
  end

  def create
    @objective = current_user.weekly_objectives.build(objective_params)
    if @objective.save
      redirect_back fallback_location: root_path, notice: "Objective created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @objective.update(objective_params)
      redirect_back fallback_location: root_path, notice: "Objective updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def link_task
    @objective = current_user.weekly_objectives.find(params[:id])
    task = current_user.tasks.find(params[:task_id])
    task.update!(weekly_objective: @objective)
    redirect_back fallback_location: weekly_objective_path(@objective)
  end

  def unlink_task
    @objective = current_user.weekly_objectives.find(params[:id])
    task = current_user.tasks.find(params[:task_id])
    task.update!(weekly_objective: nil)
    redirect_back fallback_location: weekly_objective_path(@objective)
  end

  def destroy
    @objective.destroy
    redirect_back fallback_location: root_path, notice: "Objective removed."
  end

  private

  def set_objective
    @objective = current_user.weekly_objectives.find(params[:id])
  end

  def objective_params
    params.require(:weekly_objective).permit(:title, :week_start_date, :status, :notes)
  end
end
