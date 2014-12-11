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
    @details ||= JSON.parse(request("containers/#{id}/json"))
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
    scan(request("containers/#{id}/logs?#{query}"))
  end

  def scanned_logs
    scan(logs)
  end

  def scan(binary_log)
    offset = 0
    length = binary_log.unpack("a#{offset}C4L>").last
    output = ""
    while(length)
      output << binary_log.unpack("a#{offset}C4L>a#{length}").last
      offset += 8 + length
      length = binary_log.unpack("a#{offset}C4L>").last
    end
    output
  end

  private

  def request(path)
    uri = URI.parse("#{endpoint}/#{path}")
    Net::HTTP.get_response(uri).body
  end
end
