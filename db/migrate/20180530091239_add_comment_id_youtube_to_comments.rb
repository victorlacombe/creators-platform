class AddCommentIdYoutubeToComments < ActiveRecord::Migration[5.2]
  def change
    add_column :comments, :comment_id_youtube, :string
  end
end
