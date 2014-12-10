class Host
  attr_reader :endpoint
  def initialize(endpoint)
    @endpoint = endpoint
  end

  def containers
    request("containers/json?all=1") {|data| Container.new(endpoint, data['Id']) }
  end

  def images
    request('images/json') {|data|
      repo_tags = data.fetch('RepoTags').map{|tag| RepoTag.new(tag) }
      repo_tags.map do |repo_tag|
        Image.new(endpoint, data.fetch('Id'), repo_tag)
      end
    }.flatten.sort{|a,b|
      a.repo_tag.name <=> b.repo_tag.name
    }
  end

  def tagged_images
    images.reject{|image| image.repo_tags.first.missing? }
  end

  def image(id)
    image_list = images.select{|image| image.id[0, id.length] == id}
    raise "Multiple images for id #{id}" if image_list.length > 1
    image_list.first
  end

  private

  def request(path)
    uri = URI.parse("#{endpoint}/#{path}")
    response = Net::HTTP.get_response(uri)
    JSON.parse(response.body).map{|data| yield data }
  end
end

