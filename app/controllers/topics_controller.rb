class TopicsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_topic, only: [:show, :edit, :update, :destroy]

  def index
    @topics = Topic.all
  end

  def select_image
    # @topic = Topic.new
    @reserved_image = ReservedImage.new
  end

  def detect_labels
    if params[:api_name] == "noapi"
      redirect_to select_image_topics_path, alert: "画像もしくは画像解析APIが選択されていません。"
    end

    # トピック登録のタイミングで画像を保存できるように別モデルへ一時保管する
    @reserved_image = ReservedImage.new(reserved_image_params)
    @reserved_image.save
    # unless @reserved_image.save
    #   redirect_to select_image_topics_path, alert: "画像もしくは画像解析APIが選択されていません。"
    # end

    @topic = Topic.new
    @topic.image = @reserved_image.image
    @api_name = params[:api_name]

    begin
      if @api_name == "Rekognition"
        client = Aws::Rekognition::Client.new(
          region: 'us-west-2'
        )
        @detect_labels_resp = client.detect_labels(
          image: {
            bytes: File.read(@topic.image.file.file)
          },
        )
        @detect_moderation_labels_resp = client.detect_moderation_labels(
          image: {
            bytes: File.read(@topic.image.file.file)
          }
        )

        if @detect_moderation_labels_resp.moderation_labels.present?
          redirect_to select_image_topics_path, alert: "選択した画像のラベル検出は実行できません。（セーフサーチ機能）"
        end
      end

      if @api_name == "Cloud Vision API"
        client = CloudVision.new("gungnir-001")
        vision_image = client.image(@topic.image.file.file)
        @detect_labels_resp = vision_image.labels
        @safe_search = client.safe_search(@topic.image.file.file)

        if @safe_search.adult? ||
           @safe_search.spoof? ||
           @safe_search.medical? ||
           @safe_search.violence?
          redirect_to select_image_topics_path, alert: "選択した画像のラベル検出は実行できません。（セーフサーチ機能）"
        end
      end
    rescue Exception => e
      redirect_to select_image_topics_path, alert: "画像解析APIの実行でエラーが発生しました。" + "\n" + e.message
    end
  end

  def show
    @comment = @topic.comments.build
    @comments = @topic.comments

    Notification.find(params[:notification_id]).update(read: true) if params[:notification_id]
  end

  def create
    @reserved_image = ReservedImage.find(params[:reserved_image_id])
    @topic = Topic.new(topic_params)
    @topic.user_id = current_user.id
    @topic.image = @reserved_image.image
    @api_name = params[:api_name]
    detected_labels = params[:detected_labels]
    selected_labels = params[:selected_labels]

    if selected_labels.present? && @topic.save
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

      redirect_to select_image_topics_path, alert: "トピックの投稿でエラーが発生しました。"
    end
  end

  def edit
    @api_name = @topic.image_labels.first.api
  end

  def update
    selected_labels = params[:selected_labels]
    if selected_labels.present? && @topic.update(topic_params_for_update)
      @topic.image_labels.each do |label|
        if selected_labels.include?(label.label)
          label.selected = true
        else
          label.selected = false
        end
        label.save
      end

      redirect_to topics_path, notice: "トピックを編集しました。"
    else
      render 'edit'
    end
  end

  def destroy
    @topic.destroy
    redirect_to topics_path, notice: "トピックを削除しました。"
  end

  private
    def reserved_image_params
      params.require(:reserved_image).permit(:image)
    end

    def topic_params
      params.require(:topic).permit(:image, :content)
    end

    def topic_params_for_update
      params.require(:topic).permit(:content)
    end

    def set_topic
      @topic = Topic.find(params[:id])
    end
end
