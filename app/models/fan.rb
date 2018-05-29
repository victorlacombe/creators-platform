class Fan < ApplicationRecord

  # A fan is defined as a youtube fan that commented on a video belonging to a Creator
  # The moment a fan comments on a video, the fan needs to be saved in our database

  has_many :comments
  belongs_to :memo
end
