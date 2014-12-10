class ContainersController < ApplicationController
  def index
  end

  def show
    @container = Container.new(DOCKER_ENDPOINT, params[:id])
  end
end
