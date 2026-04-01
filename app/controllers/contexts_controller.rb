class ContextsController < ApplicationController
  before_action :set_context, only: [:edit, :update, :destroy]

  def index
    @contexts = current_user.contexts.active.ordered.includes(:channels)
  end

  def new
    @context = current_user.contexts.build
  end

  def create
    @context = current_user.contexts.build(context_params)
    if @context.save
      redirect_to contexts_path, notice: "Context created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @context.update(context_params)
      redirect_to contexts_path, notice: "Context updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @context.update(archived: true)
    redirect_to contexts_path, notice: "Context archived."
  end

  private

  def set_context
    @context = current_user.contexts.find(params[:id])
  end

  def context_params
    params.require(:context).permit(:name, :color, :icon)
  end
end
