class YoutubeRefreshDataService
  def initialize(user)
    @user = user
    @youtube_api_v3 = ENV['YOUTUBE_API_V3']
    @yt_gem_account = Yt::Account.new access_token: @user.token if @user.token # If there is a token we will use it for some requests (get subscribers list)
    @yt_gem_channel = Yt::Channel.new(id: @user.channel_id_youtube)
  end

  # def refresh_all
  #   refresh_channel_data
  #   refresh_all_videos
  #   refresh_all_comments
  # end

  def refresh_public_subscribers
    unless @yt_gem_account.nil? # If the user is logged out for a long time, we can't get token
      # @yt_gem_account.subscribers
      url = "https://www.googleapis.com/youtube/v3/subscriptions?part=subscriberSnippet&maxResults=50&mySubscribers=true&access_token=#{@user.token}"
      response = RestClient.get(url)
      h_response = JSON.parse(response)
      arr_yt_subs = []
      h_response["items"].each do |subscriber|
        yt_sub_channel_id = subscriber["subscriberSnippet"]["channelId"] # this fan is subscribed
        arr_yt_subs << yt_sub_channel_id
        binding.pry
        # db_fan = Fan.find_by(channel_id_youtube: yt_sub_channel_id) # we search him in our db
        # if !db_fan.nil? # if we find him, we put him to subscribed
        #   db_fan.is_subscribed = true
        #   db_fan.save
        # end
      end
      p arr_yt_subs
    end
    return # to avoid returning anything
  end

  def refresh_channel_data
    @user.channel_name = @yt_gem_channel.title # yt makes an API Request. 'channel' is then populated with data.
    @user.channel_thumbnail = @yt_gem_channel.thumbnail_url # Does yt make a request again? Data is a bit different
    # @user.channel_comment_count = channel.comment_count # Doesn't seem to work.. Always return 0
    @user.save
    puts "---------------"
    puts "User id: #{@user.id} 's Channel data has been added/updated"
    puts "---------------"
    return # to avoid returning anything
  end

  # db_video : is persisted in the database, yt_gem_video comes fromthe gem Yt.
  def refresh_all_videos
    @count = 0 # Counter to check how many updated/new videos
    # Get all videos from Youtube
    @yt_gem_channel.videos.each do |yt_gem_video|
      db_video = @user.videos.find_by(video_id_youtube: yt_gem_video.id)
      # Check if video exists in db else we create it
      db_video = Video.new if db_video.nil?
      db_video = set_video_data(db_video, yt_gem_video)
      db_video.save
    end
    puts "---------------"
    puts "#{@count} VIDEOS have been added/updated"
    puts "---------------"
    return # to avoid returning anything
  end

  # Auth Issue because of isMine parameter -> require OAuth. Can't only use API Key.
  # def refresh_all_videos_JSON
  #   @count = 0 # Counter to check how many updated/new videos
  #   # Get all videos from Youtube
  #   max_results = 50 # limited to 50 for search requests on videos
  #   url = "https://www.googleapis.com/youtube/v3/search?part=snippet&forMine=true&maxResults=#{max_results}&type=video&key=#{@youtube_api_v3}"
  #   p url
  #   response = RestClient.get(url)
  #   h_response = JSON.parse(response)
  #   @yt_gem_channel.videos.each do |yt_gem_video|
  #     db_video = @user.videos.find_by(video_id_youtube: yt_gem_video.id)
  #     # Check if video exists in db else we create it
  #     db_video = Video.new if db_video.nil?
  #     db_video = set_video_data(db_video, h_response)
  #     db_video.save
  #     @count += 1
  #   end
  #   puts "---------------"
  #   puts "#{@count} VIDEOS have been added/updated"
  #   puts "---------------"
  #   return # to avoid returning anything
  # end

  # To try out/create youtube API requests : https://developers.google.com/apis-explorer/#p/youtube/v3/youtube.commentThreads.list?part=snippet%252Creplies&allThreadsRelatedToChannelId=UCcIZ5L8w-VXDim5r7sINIww&_h=1&
  # NOT USING YT GEM - replies param does not exist in the gem
  def refresh_all_comments
    @count = 0 # Counter to check how many updated/new comments

    # ------------------------
    # Initial comment request
    # ------------------------
    channel_id = @user.channel_id_youtube
    max_results = 100 # Youtube API V3 limit comments list to 100 results - https://developers.google.com/apis-explorer/#p/youtube/v3/youtube.commentThreads.list?part=snippet%252Creplies&maxResults=100&videoId=1cMoaxEPJ_Y&_h=18&
    url = "https://www.googleapis.com/youtube/v3/commentThreads?part=snippet%2Creplies&maxResults=#{max_results}&allThreadsRelatedToChannelId=#{channel_id}&key=#{@youtube_api_v3}"
    response = RestClient.get(url)
    h_response = JSON.parse(response)

    arr_reponse = []
    arr_reponse << h_response

    # ------------------------
    # Other comment requests (if more than one page)
    # ------------------------
    until h_response["nextPageToken"].nil? do # if There is a next page of comment we loop
      next_page_token = h_response["nextPageToken"]
      url = "https://www.googleapis.com/youtube/v3/commentThreads?part=snippet%2Creplies&maxResults=#{max_results}&pageToken=#{next_page_token}&allThreadsRelatedToChannelId=#{channel_id}&key=#{@youtube_api_v3}"
      response = RestClient.get(url)
      h_response = JSON.parse(response)
      # We add all new responses in an array
      arr_reponse << h_response
    end

    # ------------------------
    # Putting results in database
    # ------------------------
    arr_reponse.each do |h_response| # we go throught each results
      unless h_response["items"] == [] # Sometimes there can be nil results!
        h_response["items"].each do |comment_thread|
          yt_video_id = comment_thread["snippet"]["videoId"]
          db_video = @user.videos.find_by(video_id_youtube: yt_video_id)
          if !db_video.nil? # if the video exists in our db
            # we update or create a new parent comment in our db
            create_update_parent_comment(comment_thread, db_video)
            # we update or create replies/children comments in our db
            create_update_replies_comment(comment_thread, db_video)
          end
        end
      end
    end
    puts "---------------"
    puts "#{@count} COMMENTS have been added/updated"
    puts "---------------"
    return # to avoid returning anything
  end

  private

  def set_video_data(db_video, yt_gem_video)
    db_video.video_id_youtube = yt_gem_video.id
    db_video.title = yt_gem_video.title
    db_video.thumbnail = yt_gem_video.thumbnail_url
    db_video.likes = yt_gem_video.like_count
    db_video.dislikes = yt_gem_video.dislike_count
    db_video.comment_count = yt_gem_video.comment_count # we don't need it actually?
    db_video.user = @user
    return db_video
  end

  def create_update_parent_comment(comment_thread, db_video)
    parent = comment_thread["snippet"]["topLevelComment"] # shortcut to look in JSON
    yt_parent_comment_id = parent["id"] # find the comment id
    db_comment = db_video.comments.find_by(comment_id_youtube: yt_parent_comment_id) # find the id in db (nil if doesn't exist)
    db_comment = Comment.new if db_comment.nil? #If nil we create a new one

    # set the ids
    db_comment.comment_id_youtube = parent["id"] # ex. Ugzf8yYkr0lnr5neKmF4AaABAg
    db_comment.top_level_comment_id_youtube = db_comment.comment_id_youtube
    # set all other params
    db_comment = set_comment_data(db_comment, parent, db_video)
    db_comment.save
    @count += 1
  end

  def create_update_replies_comment(comment_thread, db_video)
    if !comment_thread["replies"].nil? # A comment thread may have no replies
      replies = comment_thread["replies"]["comments"]
      replies.each do |reply|
        yt_comment_id = reply["id"]
        db_comment = db_video.comments.find_by(comment_id_youtube: yt_comment_id)
        db_comment = Comment.new if db_comment.nil?

        # set the ids
        db_comment.comment_id_youtube = reply["id"] # ex. Ugzf8yYkr0lnr5neKmF4AaABAg.8gqO6MzYsEQ8gqP4sjy0C9
        db_comment.top_level_comment_id_youtube = reply["snippet"]["parentId"] # ex. Ugzf8yYkr0lnr5neKmF4AaABAg
        # set all other params
        db_comment = set_comment_data(db_comment, reply, db_video)
        db_comment.save
        @count += 1
      end
    end
  end

  def create_update_fan(fan_id, fan_avatar, fan_name)
    db_fan = Fan.find_by(channel_id_youtube: fan_id)
    db_fan = Fan.new if db_fan.nil?
    db_fan.memo = create_memo if db_fan.memo.nil?
    db_fan.channel_id_youtube = fan_id
    db_fan.profile_picture_url = fan_avatar
    db_fan.youtube_username = fan_name
    db_fan.save
    return db_fan
  end

  def create_memo
    db_memo = Memo.new
    db_memo.user = @user
    db_memo.save
    return db_memo
  end

  def set_comment_data(db_comment, shorcut, db_video)
    db_comment.content = shorcut["snippet"]["textDisplay"]
    db_comment.published_at = shorcut["snippet"]["publishedAt"]

    db_comment.video = db_video

    fan_id = shorcut["snippet"]["authorChannelId"]["value"]
    fan_avatar = shorcut["snippet"]["authorProfileImageUrl"]
    fan_name = shorcut["snippet"]["authorDisplayName"]
    db_comment.fan = create_update_fan(fan_id, fan_avatar, fan_name)
    return db_comment
  end
end
