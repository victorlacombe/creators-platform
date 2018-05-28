class CreateVideos < ActiveRecord::Migration[5.2]
  def change
    create_table :videos do |t|
      t.string :video_id_youtube
      t.string :title
      t.string :thumbnail
      t.integer :likes
      t.integer :dislikes
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
