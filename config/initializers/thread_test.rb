require 'thread'

$image_status = {}
$image_request_queue = Queue.new
$image_request_thread = Thread.new do
  loop do
    image_tag = $image_request_queue.pop
    $image_status[image_tag] = :pending unless $image_status.has_key?(image_tag)
  end
end

def update_image_status(image_tag)
  latest_id = Registry.latest_tag_id(RepoTag.new(image_tag))
  local_id = Image.new(DOCKER_ENDPOINT, image_tag).id
  $image_status[image_tag] = (local_id.start_with?(latest_id)) ? :fresh : :stale
  if $image_status[image_tag] != :fresh
    puts "#{latest_id} does not match #{local_id}"
  end
end

$image_update_thread = Thread.new do
  loop do
    unless $image_status.empty?
      pending = $image_status.detect{|k,v| v == :pending}.try(:first)
      update_image_status(pending || $image_status.keys.sample)
    end
    sleep 30
  end
end
