class Registry
  class Hub
    def latest_tag_id(repo_tag)
      uri = URI.parse("https://registry.hub.docker.com")
      uri.path = "/v1/repositories/#{repo_tag.username}/#{repo_tag.name}/tags"
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      request = Net::HTTP::Get.new(uri.request_uri)
      response = http.request(request)
      JSON.parse(response.body).find{|data| data['name'] == repo_tag.tag}.fetch('layer')
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
