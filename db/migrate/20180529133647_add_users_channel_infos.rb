class AddUsersChannelInfos < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :channel_name, :string
    add_column :users, :channel_thumbnail, :string
  end
end
