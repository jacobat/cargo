class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :set_containers_variable

  def set_containers_variable
    @containers = Host.new(DOCKER_ENDPOINT).containers
  end
end
