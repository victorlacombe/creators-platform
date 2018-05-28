class Fan < ApplicationRecord
  has_many :comments
  belongs_to :memo
end
