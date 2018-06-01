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
end
