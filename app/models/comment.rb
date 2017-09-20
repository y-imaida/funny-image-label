class Comment < ActiveRecord::Base
  validates :content, presence: true

  belongs_to :user
  belongs_to :topic
  has_many :notifications, dependent: :destroy

  def self.send_notice(comment, current_user_id)
    unless comment.topic.user_id == current_user_id
      Pusher.trigger("user_#{comment.topic.user_id}_channel", 'comment_created', {
        message: 'あなたの投稿にコメントが付きました。'
      })
    end
    Pusher.trigger("user_#{comment.topic.user_id}_channel", 'notification_created', {
      unread_counts: Notification.where(user_id: comment.topic.user.id, read: false).count
    })
  end
end
