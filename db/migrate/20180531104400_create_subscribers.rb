class CreateSubscribers < ActiveRecord::Migration[5.2]
  def change
    create_table :subscribers do |t|
      t.boolean :is_subscribed
      t.string :channel_id_youtube
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
