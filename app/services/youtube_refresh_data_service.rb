# YoutubeRefreshDataService.new("UCcIZ5L8w-VXDim5r7sINIww")

class YoutubeRefreshDataService
  def initialize(user)
    @user = user
    @yt_channel = Yt::Channel.new(id: @user.channel_id_youtube)
  end

  def update_channel_data
    @user.channel_name = yt_channel.title # yt makes an API Request. 'channel' is then populated with data.
    @user.channel_thumbnail = yt_channel.thumbnail_url # Does yt make a request again? Data is a bit different
    # @user.channel_comment_count = channel.comment_count # Doesn't seem to work.. Always return 0
  end

  def new_video_data
    @yt_channel.videos.each do |yt_video|
      if @user.videos.find_by(video_id_youtube: yt_video.id).nil?
        db_video = Videos.new
        db_video.title = yt_video.title
        db_video.thumbnail = yt_video.thumbnail_url
        db_video.likes = yt_video.like_count
        db_video.dislikes = yt_video.dislike_count
        db_video.comment_count = yt_video.comment_count
        db_video.save
      end
    end
  end

  # def update_video_data
  #   # we find the related video in our db
  #   db_video = @user.videos.find_by(video_id_youtube: yt_video.id)
  #   db_video.title = yt_video.title
  #   db_video.thumbnail = yt_video.thumbnail_url
  #   db_video.likes = yt_video.like_count
  #   db_video.dislikes = yt_video.dislike_count
  # end

  # def get_new_comments
  #   @yt_channel.videos.each do |yt_video|
  #     # we find the related video in our db
  #     db_video = @user.videos.find_by(video_id_youtube: yt_video.id)

  #     # check if numbers of comments has changed
  #     yt_comment_count = yt_video.comment_count
  #     db_comment_count = db_video.comment_count
  #     if yt_comment_count != db_comment_count
  #       # update data in db

  #     end
  #   end
  # end
end

# # # COMMENTS
# # Get all parent comments of a video
# video.comment_threads # => <Yt::Collections::CommentThreads ...>
# # Get all parent comments of a channel
# channel.comment_threads # => <Yt::Collections::CommentThreads ...>
# # content
# comment_thread.text_display
# # author
# comment_thread.author_display_name
# # published_at
# comment_thread.updated_at
# # top_level_comment_id_youtube
# comment_thread.top_level_comment

# # # FANS
# # channel_id_youtube
# # profile_picture_url
