json.extract! @video, :video_id_youtube,
                      :title,
                      :thumbnail,
                      :likes,
                      :dislikes,
                      :user_id,
                      :comment_count

json.video_owner do
  json.user @video.user
end

