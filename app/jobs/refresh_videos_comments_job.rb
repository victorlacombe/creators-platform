# Ex. Can be called and exec by Sidekiq with : RefreshVideosCommentsJob.perform_later(User.first.id)
# Refresh a User's VIDEOS, COMMENTS (AND FANS) DATA
class RefreshVideosCommentsJob < ApplicationJob
  queue_as :default

  def perform(user_id)
    user = User.find(user_id)
    puts "--------------------------------------------"
    puts "BEGIN - refreshing VIDEOS & COMMENTS (& FANS) DATA for user: ID #{user_id} - #{user.email}"
    refresher = YoutubeRefreshDataService.new(user)
    refresher.refresh_all_videos
    refresher.refresh_all_comments # Also refresh Fans, as they are linked to comments
    puts "DONE - refreshing VIDEOS & COMMENTS (& FANS) DATA for user: ID #{user_id} - #{user.email}"
    puts "--------------------------------------------"
  end
end
