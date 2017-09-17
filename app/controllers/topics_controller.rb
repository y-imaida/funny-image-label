class TopicsController < ApplicationController
  def index
    @topics = Topic.all
  end

  def select_image
    @topic = Topic.new
  end

  def detect_labels
    @topic = Topic.new(topic_params)
    @api_name = params[:api_name]

    if @api_name == "Rekognition"
      client = Aws::Rekognition::Client.new(
        region: 'us-west-2'
      )
      @detect_labels_resp = client.detect_labels(
        image: {
          bytes: File.read(@topic.image.file.file)
        },
        max_labels: 20,
      )
    elsif @api_name == "Cloud Vision API"
      client = CloudVision.new("gungnir-001")
      vision_image = client.image(@topic.image.file.file)
      @detect_labels_resp = vision_image.labels
      @safe_search = client.safe_search(@topic.image.file.file)
    end
  end

  def create
    @labels = params[:labels]
    binding.pry

    redirect_to topics_path, notice: "トピックを投稿しました！"
  end

  private
    def topic_params
      params.require(:topic).permit(:image)
    end
end
