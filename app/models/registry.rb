class Registry
  class Hub
    def latest_tag_id(repo_tag)
      uri = URI.parse("https://registry.hub.docker.com")
      if repo_tag.username.nil?
        uri.path = "/v1/repositories/#{repo_tag.name}/tags"
      else
        uri.path = "/v1/repositories/#{repo_tag.username}/#{repo_tag.name}/tags"
      end
      http = Net::HTTP.new(uri.host, uri.port)
      http.read_timeout = 2
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      request = Net::HTTP::Get.new(uri.request_uri)
      response = http.request(request)
      case response
      when Net::HTTPNotFound
        nil
      else
        JSON.parse(response.body).find{|data| data['name'] == repo_tag.tag}.fetch('layer')
      end
    rescue Exception => ex
      puts ex.class
      puts "Could not retrieve tag_id for #{repo_tag} / #{uri}"
      puts ex.message
      nil
    end
  end

  class Private
    def latest_tag_id(repo_tag)
      uri = URI.parse("http://#{repo_tag.registry_host}")
      uri.path = "/v1/repositories/#{repo_tag.username}/#{repo_tag.name}/tags/#{repo_tag.tag}"
      http = Net::HTTP.new(uri.host, uri.port)
      request = Net::HTTP::Get.new(uri.request_uri)
      response = http.request(request)
      response.body.gsub('"', '')
    rescue Exception => ex
      puts ex.class
      puts "Could not retrieve tag_id for #{repo_tag} / #{uri}"
      puts ex.message
      nil
    end
  end

  class << self
    def latest_tag_id(repo_tag)
      if repo_tag.registry_host.nil?
        Hub.new.latest_tag_id(repo_tag)
      else
        Private.new.latest_tag_id(repo_tag)
      end
    end
  end
end
