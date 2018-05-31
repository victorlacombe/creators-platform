class Memo < ApplicationRecord
  belongs_to :user
  has_one :fan, dependent: :destroy
end
