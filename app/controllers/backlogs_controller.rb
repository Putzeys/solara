class BacklogsController < ApplicationController
  def show
    @tasks = current_user.tasks
      .backlog
      .top_level
      .ordered
      .includes(:channel, :subtasks)

    @channels = current_user.channels.active.ordered
  end
end
