class Fan < ApplicationRecord
  has_many :comments
  belong_to :memo
end
