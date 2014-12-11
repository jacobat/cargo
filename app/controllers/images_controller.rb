class ImagesController < ApplicationController
  def index
    @images = Host.new(DOCKER_ENDPOINT).images
  end

  def show
    @images = Host.new(DOCKER_ENDPOINT).images
    @image = Image.new(DOCKER_ENDPOINT, params[:id])
  end
end
