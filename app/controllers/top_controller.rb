require "google/cloud/vision"

class TopController < ApplicationController
  def index
    client = Aws::Rekognition::Client.new(
      region: 'us-west-2',
    )
    @moderation_resp = client.detect_moderation_labels(
      image: {
        bytes: File.read('./noro.jpg')
      }
    )
    @label_resp = client.detect_labels(
      image: {
        bytes: File.read('./noro.jpg')
      },
      max_labels: 10,
    )

    project_id = "gungnir-001"
    image_path = "./noro.jpg"
    # image_path = "./snis.jpg"

    vision = Google::Cloud::Vision.new(
      project: project_id,
      keyfile: "config/gungnir-001-viewer.json"
    )
    @image = vision.image image_path
    @safe_search = @image.safe_search
  end
end
