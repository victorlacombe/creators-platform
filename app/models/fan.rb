class Fan < ApplicationRecord

  # A fan is defined as a youtube fan that commented on a video belonging to a Creator
  # The moment a fan comments on a video, the fan needs to be saved in our database

  has_many :commentss
  belongs_to :memo

  # Return False if user doesn't display his subscriptions list or if he is not subscribed
  # Return True if subscribed
  def is_subscribed?(fan_id)
    fan_channel_id = Fan.find(fan_id).channel_id_youtube
    subscriber = current_user.subscribers.find_by(fan_channel_id: fan_channel_id)
    sub_status = subscriber.nil? ? false : subscriber.is_subscribed # if subscriber exists in db, we show his status, else it's false anyway
    return sub_status
  end
end
