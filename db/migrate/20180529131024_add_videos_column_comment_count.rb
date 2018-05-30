class AddVideosColumnCommentCount < ActiveRecord::Migration[5.2]
  def change
    add_column :videos, :comment_count, :integer
  end
end
