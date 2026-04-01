class ChannelsController < ApplicationController
  before_action :set_channel, only: [:show, :edit, :update, :destroy]

  def index
    @channels = current_user.channels.active.ordered.includes(:context)
  end

  def show
    @tasks = @channel.tasks.top_level.ordered.includes(:subtasks)
  end

  def new
    @channel = current_user.channels.build
  end

  def create
    @channel = current_user.channels.build(channel_params)
    if @channel.save
      redirect_to channels_path, notice: "Channel created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @channel.update(channel_params)
      redirect_to channels_path, notice: "Channel updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @channel.update(archived: true)
    redirect_to channels_path, notice: "Channel archived."
  end

  private

  def set_channel
    @channel = current_user.channels.find(params[:id])
  end

  def channel_params
    params.require(:channel).permit(:name, :color, :icon, :context_id)
  end
end
