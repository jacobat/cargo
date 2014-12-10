class ImagesController < ApplicationController
  def index
    @images = Host.new(DOCKER_ENDPOINT).images
  end

  def show
    @image = Image.new(DOCKER_ENDPOINT, params[:id])
  end
end

