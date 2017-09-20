module NotificationsHelper
  def posted_time(time)
    time > Date.today ? "#{time_ago_in_words(time)}" : time.strftime('%m月%d日')
  end

  def get_notif_status_string(read)
    read ? '既読' : '未読'
  end
end
