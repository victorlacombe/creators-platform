class RefreshPublicSubscribersJob < ApplicationJob
  queue_as :default

  def perform(user_id)
    user = User.find(user_id)
    puts "--------------------------------------------"
    puts "JOB - refreshing SUBSCRIBERS DATA for user: ID #{user_id} - #{user.email}"
    refresher = YoutubeRefreshDataService.new(user)
    refresher.refresh_public_subscribers
  end
end
