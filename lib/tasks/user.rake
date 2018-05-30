namespace :user do
  desc "Refresh for ALL USERS the DB with new/updated COMMENTS, VIDEOS (and FANS as they are linked to comments)"
  count = 1
  task refresh_comments_videos_all: :environment do
    users = User.all
    users.each do |user|
      puts "--------------------------------------------"
      puts "Enqueuing DB update (VIDEOS, COMMENTS & FANS): #{count} / #{users.size} users.."
      puts "--------------------------------------------"
      RefreshVideosCommentsJob.perform_later(user.id)
      count += 1
    end
  end

  desc "Refresh for ALL USERS the DB with new/updated CHANNEL DATA"
  count = 1
  task refresh_channel_data_all: :environment do
    users = User.all
    users.each do |user|
      puts "--------------------------------------------"
      puts "Enqueuing DB update (CHANNEL DATA): #{count} / #{users.size} users.."
      puts "--------------------------------------------"
      RefreshChannelDataJob.perform_later(user.id)
      count += 1
    end
  end

end
