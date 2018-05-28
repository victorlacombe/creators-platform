class CreateComments < ActiveRecord::Migration[5.2]
  def change
    create_table :comments do |t|
      t.string :content
      t.datetime :published_at
      t.boolean :is_pinned
      t.string :top_level_comment_id_youtube
      t.references :video, foreign_key: true
      t.references :fan, foreign_key: true

      t.timestamps
    end
  end
end
