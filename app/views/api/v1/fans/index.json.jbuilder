json.array! @fans do |fan|
  json.extract! fan, :youtube_username,
                     :channel_id_youtube,
                     :profile_picture_url,
                     :memo_id
end
