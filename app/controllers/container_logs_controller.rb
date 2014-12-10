class ContainerLogsController < ApplicationController
  def show
    @container = Container.new(DOCKER_ENDPOINT, params[:id])
  end
end

