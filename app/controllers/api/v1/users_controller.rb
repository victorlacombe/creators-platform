class Api::V1::UsersController < Api::V1::BaseController
  skip_after_action :verify_authorized

  def verif
    query = params[:query]
    users = User.where("channel_id_youtube ILIKE ?", "%#{query}%")
    raise "Channel not found" unless users.any?
  end
end
