class Host
  attr_reader :endpoint
  def initialize(endpoint)
    @endpoint = endpoint
  end

  def containers
    uri = URI.parse("#{endpoint}/containers/json?all=1")
    response = Net::HTTP.get_response(uri)
    JSON.parse(response.body).map{|data| Container.new(endpoint, data['Id']) }
  end
end

