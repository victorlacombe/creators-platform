# Ex. Can be called and exec by Sidekiq with : RefreshChannelDataJob.perform_later(User.first.id)
# Refresh a User's CHANNEL DATA
class RefreshChannelDataJob < ApplicationJob
  queue_as :default

  def perform(user_id)
    user = User.find(user_id)
    puts "--------------------------------------------"
    puts "BEGIN - refreshing CHANNEL DATA for user: ID #{user_id} - #{user.email}"
    refresher = YoutubeRefreshDataService.new(user)
    refresher.refresh_channel_data
    puts "DONE - refreshing CHANNEL DATA for user: ID #{user_id} - #{user.email}"
    puts "--------------------------------------------"
  end
end
