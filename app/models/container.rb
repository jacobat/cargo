class Container
  attr_reader :endpoint, :id
  def initialize(endpoint, id)
    @endpoint = endpoint
    @id = id
  end

  def to_s
    "#{info['State']['Running']}"
  end

  def running?
    info['State']['Running']
  end

  def restarting?
    info['State']['Restarting']
  end

  def paused?
    info['State']['Paused']
  end

  def state
    if running?
      "running"
    elsif restarting?
      "restarting"
    elsif paused?
      "paused"
    else
      "off"
    end
  end

  def short_id
    id[0,6]
  end

  def name
    info['Name'].sub(/^\//, '')
  end

  def ports
    info['NetworkSettings']['Ports'] || []
  end

  def info
    @details ||= JSON.parse(request("containers/#{id}/json").body)
  end

  def logs
    @logs ||= logs_for(stdout: 1, stderr: 1)
  end

  def stdout
    @stdout ||= logs_for(stdout: 1)
  end

  def stderr
    @stderr ||= logs_for(stderr: 1)
  end

  def logs_for(options)
    query = options.map{|k,v| "#{k}=#{v}" }.join("&")
    response = request("containers/#{id}/logs?#{query}")
    case response['Content-Type']
    when 'application/octet-stream'
      scan(response.body)
    when 'text/plain; charset=utf-8'
      response.body
    else
      raise "Unknown content type"
    end
  end

  def scanned_logs
    scan(logs)
  end

  def tunnel_logs
    options = { stdout: 1, stderr: 1, follow: 1 }
    query = options.map{|k,v| "#{k}=#{v}" }.join("&")
    bytes_to_read = 0
    buffer = ""
    stream_request("containers/#{id}/logs?#{query}") do |response, chunk|
      if response['Content-Type'] == 'text/plain; charset=utf-8'
        yield chunk
      else
        if bytes_to_read < 0
          raise "Something went wrong, bytes to read < 0"
        end
        if bytes_to_read == 0
          bytes_to_read = chunk.unpack("C4L>").last
        else
          new_string = chunk.unpack('a*').join
          buffer << new_string
          bytes_to_read = bytes_to_read - new_string.length
          if bytes_to_read == 0
            yield buffer
            buffer = ""
          end
        end
      end
    end
  end

  def scan(binary_log)
    offset = 0
    length = binary_log.unpack("C4L>").last
    output = ""
    while(length)
      output << binary_log.unpack("a#{offset}C4L>a#{length}").last
      offset += 8 + length
      length = binary_log.unpack("a#{offset}C4L>").last
    end
    output
  end

  private

  def stream_request(path)
    uri = URI.parse("#{endpoint}/#{path}")
    Net::HTTP.start(uri.host, uri.port) do |http|
      request = Net::HTTP::Get.new uri.request_uri
      http.request request do |response|
        response.read_body do |chunk|
          yield [response.header, chunk]
        end
      end
    end
  end

  def request(path)
    uri = URI.parse("#{endpoint}/#{path}")
    Net::HTTP.get_response(uri)
  end
end
