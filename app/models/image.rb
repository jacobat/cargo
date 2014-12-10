class Image
  attr_reader :endpoint, :repo_tag

  def initialize(endpoint, ref, repo_tag = nil)
    @endpoint  = endpoint
    @repo_tag = repo_tag
    @ref       = ref
  end

  def id
    data['Id']
  end

  def data
    @data ||= request("images/#{@ref}/json")
  end

  def created
    Time.parse(data['Created'])
  end

  def parent
    if data['Parent']
      Image.new(endpoint, data['Parent'])
    else
      nil
    end
  end

  def size
    data['Size']
  end

  def history
    request("images/#{id}/history")
  end

  def short_id
    id[0,8]
  end

  def fresh?
    $image_status[repo_tag.to_s] == :fresh
  end

  private

  def request(path)
    uri = URI.parse("#{endpoint}/#{path}")
    JSON.parse(Net::HTTP.get_response(uri).body)
  end
end
