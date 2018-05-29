class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable, omniauth_providers: [:google_oauth2]
  has_many :videos
  has_many :memos
  after_create :get_channel_id_youtube

  def self.from_omniauth(access_token)
      data = access_token.info
      user = User.where(email: data['email']).first

      # Uncomment the section below if you want users to be created if they don't exist
      unless user
          user = User.create(first_name: data['first_name'],
            last_name: data['last_name'],
            email: data['email'],
            password: Devise.friendly_token[0,20],
            provider: access_token['provider'],
            uid: access_token['uid'],
            token: access_token.credentials['token'],
            token_expiry: Time.at(access_token.credentials['expires_at'])
          )
      end
      user
  end

  private

  def get_channel_id_youtube
    url = "https://www.googleapis.com/youtube/v3/channels?part=id&mine=true&access_token=#{self.token}"
    data_serialized = RestClient.get(url)
    data = JSON.parse(data_serialized)
    self.channel_id_youtube = data["items"].first["id"]
    self.save
  end
end
