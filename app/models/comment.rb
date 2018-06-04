class Comment < ApplicationRecord
  belongs_to :video
  belongs_to :fan

  # Method used in the controller, to toggle is_pinned
  def toggle_is_pinned!
    self.is_pinned = (self.is_pinned ? false : true) # will change true to false and false to true
  end
end
