json.array! @videos do |video|
  json.extract! video, :video_id_youtube,
                       :title,
                       :thumbnail,
                       :likes,
                       :dislikes,
                       :user_id,
                       :comment_count
end
