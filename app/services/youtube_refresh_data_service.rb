# YoutubeRefreshDataService.new(id: "UCcIZ5L8w-VXDim5r7sINIww")

class YoutubeRefreshDataService
  def initialize(user)
    @user = user
    @yt_channel = Yt::Channel.new(id: @user.channel_id_youtube)
  end

  def refresh_channel_data
    @user.channel_name = @yt_channel.title # yt makes an API Request. 'channel' is then populated with data.
    @user.channel_thumbnail = @yt_channel.thumbnail_url # Does yt make a request again? Data is a bit different
    # @user.channel_comment_count = channel.comment_count # Doesn't seem to work.. Always return 0
    @user.save
  end

  def refresh_all_videos
    # Get all videos from Youtube
    @yt_channel.videos.each do |yt_video|
      # Check if video exists in db
      if @user.videos.find_by(video_id_youtube: yt_video.id).nil?
        # video is not existing, we create a new one
        db_video = Videos.new
        db_video = set_video_data(db_video, yt_video)
      else
        # video exists, we update the existing one
        db_video = @user.videos.find_by(video_id_youtube: yt_video.id)
        db_video = set_video_data(db_video, yt_video)
      end
      db_video.save
    end
  end

  def refresh_all_comments(yt_video)
    @yt_channel.videos.each do |yt_video|
      # Check if video exists in db
      if @user.videos.find_by(video_id_youtube: yt_video.id).nil?
        # Video does not exist in db. We do nothing.
      else
        # video exists, we update the comments
        if comment_count_changed?(yt_video, db_video)
          # update data in db
          @user.videos.comments
          comments = yt_video.comment_threads # Get all parent comments of a video
          comments.each do |comment|
            comment.text_display # content
            comment_thread.author_display_name # author
            comment_thread.updated_at # published_at
            comment_thread.top_level_comment # top_level_comment_id_youtube
          end
        else
          # we do nothing. However we may miss a comment "edit" or if there is a add + delete of comments.
        end
      end
    end
  end

  private

  def set_video_data(db_video, yt_video)
    db_video.title = yt_video.title
    db_video.thumbnail = yt_video.thumbnail_url
    db_video.likes = yt_video.like_count
    db_video.dislikes = yt_video.dislike_count
    db_video.comment_count = yt_video.comment_count
    return db_video
  end

  def comment_count_changed?(yt_video, db_video)
    # check if numbers of comments has changed
    yt_comment_count = yt_video.comment_count
    db_comment_count = db_video.comment_count
    yt_comment_count != db_comment_count ? true : false
  end

  def set_comment_data()
  end
end

# # FANS
# channel_id_youtube
# profile_picture_url
