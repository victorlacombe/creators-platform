class AddIsSubscribedToFans < ActiveRecord::Migration[5.2]
  def change
    add_column :fans, :is_subscribed, :boolean, null: false, default: false
  end
end
