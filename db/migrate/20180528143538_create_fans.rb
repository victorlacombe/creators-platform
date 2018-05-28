class CreateFans < ActiveRecord::Migration[5.2]
  def change
    create_table :fans do |t|
      t.string :username
      t.string :channel_id_youtube
      t.string :profile_picture_url
      t.references :memo, foreign_key: true

      t.timestamps
    end
  end
end
