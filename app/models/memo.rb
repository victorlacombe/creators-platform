class Memo < ApplicationRecord
  belongs_to :user
  has_one :fan
end
