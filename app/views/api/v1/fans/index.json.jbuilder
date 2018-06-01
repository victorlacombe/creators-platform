json.array! @fans do |fan|
  json.extract! fan, :id,
                     :youtube_username,
                     :channel_id_youtube,
                     :profile_picture_url,
                     :memo_id

  json.comments fan.comments do |comment|
    json.extract! comment, :content,
                           :published_at,
                           :is_pinned,
                           :top_level_comment_id_youtube,
                           :video_id,
                           :fan_id,
                           :comment_id_youtube
  end

  json.memo do
    json.memo_details fan.memo
  end
end
