json.array! @users do |user|
  json.extract! user, :channel_id_youtube
end
