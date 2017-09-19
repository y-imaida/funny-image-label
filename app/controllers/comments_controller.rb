class CommentsController < ApplicationController
  before_action :set_comment_and_topic, only:[:edit, :update, :destroy]

  def create
    @comment = current_user.comments.build(comment_params)
    @topic = @comment.topic

    respond_to do |format|
      if @comment.save
        format.js {render :index}
      end
    end
  end

  def edit
  end

  def update
    if @comment.update(comment_params)
      redirect_to topic_path(@topic), notice: 'コメントを編集しました。'
    else
      render 'edit'
    end
  end

  def destroy
    @comment.destroy
    respond_to do |format|
      format.js {render :index}
    end
  end

  private
    def comment_params
      params.require(:comment).permit(:topic_id, :content)
    end

    def set_comment_and_topic
      @comment = Comment.find(params[:id])
      @topic = @comment.topic
    end
end
