class AddOmniauthChannelToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :channel_id_youtube, :string
  end
end
