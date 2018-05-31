

namespace :user do
  # ---------------------------------------------
  # TASKS FOR ALL USERS
  # ---------------------------------------------

  desc "Refresh for ALL USERS | EVERYTHING"
  count = 1
  task refresh_everything_all: :environment do
    users = User.all
    users.each do |user|
      puts "--------------------------------------------"
      puts "Enqueuing DB update (CHANNEL DATA): #{count} / #{users.size} users.."
      puts "--------------------------------------------"
      RefreshChannelDataJob.perform_later(user.id)
      puts "--------------------------------------------"
      puts "Enqueuing DB update (VIDEOS, COMMENTS & FANS): #{count} / #{users.size} users.."
      puts "--------------------------------------------"
      RefreshVideosCommentsJob.perform_later(user.id)
      puts "--------------------------------------------"
      puts "Enqueuing DB update (SUBSCRIBERS): #{count} / #{users.size} users.."
      puts "--------------------------------------------"
      RefreshPublicSubscribersJob.perform_later(user.id)
      count += 1
    end
    puts "--------------------------------------------"
    puts "Enqueuing DB update EVERYTHING: DONE"
    puts "--------------------------------------------"
  end

  # -----------------
  # Tasks ALL USERS - perform_later ! done by sidekiq
  # ex: rails user:refresh_channel_data_all
  desc "Refresh for ALL USERS | the DB with new/updated COMMENTS, VIDEOS (and FANS as they are linked to comments)"
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
    puts "--------------------------------------------"
    puts "Enqueuing DB update (VIDEOS, COMMENTS & FANS): DONE"
    puts "--------------------------------------------"
  end

  desc "Refresh for ALL USERS | the DB with new/updated CHANNEL DATA"
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
    puts "--------------------------------------------"
    puts "Enqueuing DB update (CHANNEL DATA): DONE"
    puts "--------------------------------------------"
  end

  desc "Refresh for ALL USERS | the DB with SUBSCRIBERS"
  count = 1
  task refresh_subscribers_all: :environment do
    users = User.all
    users.each do |user|
      puts "--------------------------------------------"
      puts "Enqueuing DB update (SUBSCRIBERS): #{count} / #{users.size} users.."
      puts "--------------------------------------------"
      RefreshPublicSubscribersJob.perform_later(user.id)
      count += 1
    end
    puts "--------------------------------------------"
    puts "Enqueuing DB update (SUBSCRIBERS): DONE"
    puts "--------------------------------------------"
  end

  # -----------------
  # Tasks ONE USER - perform_now !! done directly by current server
  # Update user of id 42 with this command
  # ex: noglob rails user:refresh_comments_videos_one[42]
  desc "Refresh for ONE USER | EVERYTHING"

  task :refresh_everything_one, [:user_id] => :environment do |t, args|
  user = User.find(args[:user_id])
    puts "--------------------------------------------"
    puts "Enqueuing DB update (CHANNEL DATA): #{user.email}..."
    puts "--------------------------------------------"
    RefreshChannelDataJob.perform_later(user.id)
    puts "--------------------------------------------"
    puts "Enqueuing DB update (VIDEOS, COMMENTS & FANS): #{user.email}..."
    puts "--------------------------------------------"
    RefreshVideosCommentsJob.perform_later(user.id)
    puts "--------------------------------------------"
    puts "Enqueuing DB update (SUBSCRIBER): #{user.email}..."
    puts "--------------------------------------------"
    RefreshPublicSubscribersJob.perform_later(user.id)
  end

  # ---------------------------------------------
  # TASKS FOR ONE USER
  # ---------------------------------------------

  desc "Refresh for ONE USER | the DB with new/updated COMMENTS, VIDEOS (and FANS as they are linked to comments)"
  task :refresh_comments_videos_one, [:user_id] => :environment do |t, args|
    user = User.find(args[:user_id])
    puts "--------------------------------------------"
    puts "Enqueuing DB update (VIDEOS, COMMENTS & FANS) #{user.email}..."
    puts "--------------------------------------------"
    RefreshVideosCommentsJob.perform_later(user.id)
    # rake task will return when job is _done_
    puts "--------------------------------------------"
    puts "Enqueuing DB update (VIDEOS, COMMENTS & FANS) #{user.email} - DONE"
    puts "--------------------------------------------"
  end

  desc "Refresh for ONE USER | the DB with new/updated CHANNEL DATA"
  task :refresh_channel_data_one, [:user_id] => :environment do |t, args|
    user = User.find(args[:user_id])
    puts "--------------------------------------------"
    puts "Enqueuing DB update (Channel Data) #{user.email}..."
    puts "--------------------------------------------"
    RefreshChannelDataJob.perform_later(user.id)
    # rake task will return when job is _done_
    puts "--------------------------------------------"
    puts "Enqueuing DB update (Channel Data) #{user.email} - DONE"
    puts "--------------------------------------------"
  end

  desc "Refresh for ONE USER | the DB with new/updated CHANNEL DATA"
  task :refresh_channel_data_one, [:user_id] => :environment do |t, args|
    user = User.find(args[:user_id])
    puts "--------------------------------------------"
    puts "Enqueuing DB update (SUBSCRIBER) #{user.email}..."
    puts "--------------------------------------------"
    RefreshPublicSubscribersJob.perform_later(user.id)
    # rake task will return when job is _done_
    puts "--------------------------------------------"
    puts "Enqueuing DB update (SUBSCRIBER) #{user.email} - DONE"
    puts "--------------------------------------------"
  end
end
