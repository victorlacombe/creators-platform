json.array! @comments do |comment|
  json.extract! comment, :content,
                         :published_at,
                         :is_pinned,
                         :top_level_comment_id_youtube,
                         :video_id,
                         :fan_id,
                         :comment_id_youtube
end
