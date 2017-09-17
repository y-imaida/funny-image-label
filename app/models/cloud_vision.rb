require "google/cloud/vision"

class CloudVision
  attr_reader :vision_client

  def initialize(project_id)
    @vision_client = Google::Cloud::Vision.new(
      project: project_id,
      keyfile: "config/gungnir-001-viewer.json"
    )
  end

  def image(image_path)
    @vision_client.image image_path
  end

  def safe_search(image_path)
    self.image(image_path).safe_search
  end
end
