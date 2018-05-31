class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable, omniauth_providers: [:google_oauth2]
  has_many :videos
  has_many :memos
  has_many :subscribers
  after_create :get_channel_id_youtube

  def self.from_omniauth(request_data)
      data = request_data.info
      user = User.where(email: data['email']).first

      # Uncomment the section below if you want users to be created if they don't exist
      unless user
          user = User.create(first_name: data['first_name'],
            last_name: data['last_name'],
            email: data['email'],
            password: Devise.friendly_token[0,20],
            provider: request_data['provider'],
            uid: request_data['uid'],
            token: request_data.credentials['token'],
            token_expiry: Time.at(request_data.credentials['expires_at']),
            refresh_token: request_data.credentials['refresh_token']
          )
      end
      user
  end

  def refresh_token_if_expired
    if token_expired?
      response    = RestClient.post "https://accounts.google.com/o/oauth2/token", :grant_type => 'refresh_token', :refresh_token => self.refresh_token, :client_id => ENV['GOOGLE_CLIENT_ID'], :client_secret => ENV['GOOGLE_CLIENT_SECRET']
      refreshhash = JSON.parse(response.body)

      # token_will_change!
      # expiresat_will_change!

      self.token     = refreshhash['access_token']
      self.token_expiry = DateTime.now + refreshhash["expires_in"].to_i.seconds

      self.save
      puts 'Saved'
    end
  end

  def token_expired?
    expiry = Time.at(self.token_expiry)
    return true if expiry < Time.now # expired token, so we should quickly return
    token_expires_at = expiry
    save if changed?
    false # token not expired. :D
  end

  private

  def get_channel_id_youtube
    if token
      url = "https://www.googleapis.com/youtube/v3/channels?part=id&mine=true&access_token=#{self.token}"
      data_serialized = RestClient.get(url)
      data = JSON.parse(data_serialized)
      self.channel_id_youtube = data["items"].first["id"]
      self.save
    end
  end
end
