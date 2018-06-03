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

  # The following methods are applied in the index on @fans
  # => after pre-selection of the user's fans in the controller
  # Return an array of most recent fans
  def most_recent_fans(user, max)
    fans = user.fans
    fans_filtered = fans.group_by { |fan| fan.comments.count }.sort_by { |count, fans| -count }
    # .......... NEED TO BE FINISHED
  end

  # Return an array of churning fans (no comments on the last 2 videos, ordered from most comments done)
  def churning_fans
  end

  # Return an array of most loyal fans (most comments done and not churning)
  def most_loyal_fans
  end
end
