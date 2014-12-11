class ContainersController < ApplicationController
  def index
    @containers = Host.new(DOCKER_ENDPOINT).containers
  end

  def show
    @containers = Host.new(DOCKER_ENDPOINT).containers
    @container = Container.new(DOCKER_ENDPOINT, params[:id])
  end
end
