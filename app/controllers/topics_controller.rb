class TopicsController < ApplicationController
  def index
    @topics = Topic.all
  end

  def select_image
    # @topic = Topic.new
    @reserved_image = ReservedImage.new
  end

  def detect_labels
    @reserved_image = ReservedImage.new(reserved_image_params)
    @reserved_image.save

    # @topic = Topic.new(topic_params)
    @topic = Topic.new
    @topic.image = @reserved_image.image
    @api_name = params[:api_name]

    if @api_name == "Rekognition"
      client = Aws::Rekognition::Client.new(
        region: 'us-west-2'
      )
      @detect_labels_resp = client.detect_labels(
        image: {
          bytes: File.read(@topic.image.file.file)
        },
      )
    elsif @api_name == "Cloud Vision API"
      client = CloudVision.new("gungnir-001")
      vision_image = client.image(@topic.image.file.file)
      @detect_labels_resp = vision_image.labels
      @safe_search = client.safe_search(@topic.image.file.file)
    end
  end

  def create
    @reserved_image = ReservedImage.find(params[:reserved_image_id])
    @topic = Topic.new(topic_params)
    @topic.user_id = current_user.id
    @topic.image = @reserved_image.image
    @api_name = params[:api_name]
    detected_labels = params[:detected_labels]
    selected_labels = params[:selected_labels]

    if @topic.save
      detected_labels.each do |dls|
        dls.split(",").each_slice(2) do |dl|
          @image_label = @topic.image_labels.build
          @image_label.api = @api_name
          @image_label.label = dl[0]
          @image_label.score = dl[1].to_f
          @image_label.selected = true if selected_labels.include?(dl[0])

          @image_label.save
        end
      end

      @reserved_image.destroy

      redirect_to topics_path, notice: "トピックを投稿しました。"
    else
      @reserved_image.destroy

      redirect_to select_image_topics_path
    end
  end

  private
    def reserved_image_params
      params.require(:reserved_image).permit(:image)
    end

    def topic_params
      params.require(:topic).permit(:image, :content)
    end
end
