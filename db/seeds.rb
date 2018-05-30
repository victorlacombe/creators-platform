# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)


10.times do |fan|
  Fan.create([
    {youtube_username: 'Lajika'},
    {channel_id_youtube: 'UCfM3zsQsOnfWNUppiycmBuw'},
    {profile_picture_url: 'https://yt3.ggpht.com/-qtnbIDAbSNQ/AAAAAAAAAAI/AAAAAAAAAAA/bb4rTjplM5Y/s288-mo-c-c0xffffffff-rj-k-no/photo.jpg'},
    {memo_id: '1'}
])
end
