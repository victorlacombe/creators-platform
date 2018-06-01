json.array! @memos do |memo|
  json.extract! memo, :id, :content, :user_id
end
