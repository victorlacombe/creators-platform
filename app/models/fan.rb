class Fan < ApplicationRecord

  # A fan is defined as a youtube fan that commented on a video belonging to a Creator
  # The moment a fan comments on a video, the fan needs to be saved in our database

  has_many :comments, dependent: :destroy
  belongs_to :memo
  has_many :users, through: :memo

  # Return False if user doesn't display his subscriptions list or if he is not subscribed
  # Return True if subscribed
  def is_subscribed?(user)
    fan_channel_id_youtube = self.channel_id_youtube
    subscriber = user.subscribers.find_by(channel_id_youtube: fan_channel_id_youtube)
    sub_status = subscriber.nil? ? false : subscriber.is_subscribed # if subscriber exists in db, we show his status, else it's false anyway
    return sub_status
  end

  # Return an array of fans [fan, fan, fan] that has commented n_times in total
  def self.n_times_fans(user, n_times)
    # fans = user.fans.reject{ |fan| fan.channel_id_youtube == user.channel_id_youtube} if user.fans # Rejecting the current_user from results
    fans = User.includes(fans: :comments).find(user.id).fans # Includes is to avoid N+1 requests, and instaed make a single big request. See tutorial at le Wagon.
    rejected_user_fans = fans.reject{ |fan| fan.channel_id_youtube == user.channel_id_youtube} unless fans.empty?
    fans_filtered = rejected_user_fans.group_by { |fan| fan.comments.size }[n_times] if rejected_user_fans # Hash of fans by comment count, we select fans that have commented n_times
    fans_filtered_recent = fans_filtered.select { |fan| fan.comments.order(published_at: :desc).first.published_at > (Date.today - 1.months) } if fans_filtered# select the fans that have recently commented
    fans_filtered_recent.nil? ? [] : fans_filtered_recent #if the result is nil, we prefer to return an empty array to avoid bug in view
  end

  # Return an array of churning fans (no comments the last 2 months)
  def self.churning_fans(user)
    fans = User.includes(fans: :comments).find(user.id).fans
    rejected_user_fans = fans.reject{ |fan| fan.channel_id_youtube == user.channel_id_youtube} unless fans.empty?
    fans_filtered = rejected_user_fans.group_by { |fan| fan.comments.size }.sort_by { |count, fans| -count } if rejected_user_fans
    fans_filtered_recent = []
    if fans_filtered
      fans_filtered.each do |count, fan_arr|
        fans_filtered_recent = fans_filtered_recent + fan_arr.select { |fan| fan.comments.order(published_at: :desc).first.published_at < (Date.today - 2.months) }
      end
    end
    fans_filtered_recent.nil? ? [] : fans_filtered_recent  #if the result is nil, we prefer to return an empty array to avoid bug in view
  end

  # Return an array of an array [[comment_count, fan],... ] of most loyal fans (most comments done and not churning)
  def self.top_fans(user)
    fans = User.includes(fans: :comments).find(user.id).fans
    rejected_user_fans = fans.reject{ |fan| fan.channel_id_youtube == user.channel_id_youtube} unless fans.empty?
    fans_filtered = rejected_user_fans.group_by { |fan| fan.comments.size }.sort_by { |count, fans| -count } if fans
    fans_filtered.nil? ? [] : fans_filtered
  end
end
