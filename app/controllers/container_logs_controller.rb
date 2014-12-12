require 'reloader/sse'
class ContainerLogsController < ActionController::Base
  include ActionController::Live

  def show
    container = Container.new(DOCKER_ENDPOINT, params[:id])
    response.headers['Content-Type'] = 'text/event-stream'
    sse = Reloader::SSE.new(response.stream)

    container.tunnel_logs do |chunk|
      sse.write({ line: chunk }, { event: 'log' })
    end
  rescue IOError => ex
  rescue Exception => ex
    puts "Exception: #{ex.message}"
    puts ex.backtrace
  ensure
    response.stream.close
  end
end

