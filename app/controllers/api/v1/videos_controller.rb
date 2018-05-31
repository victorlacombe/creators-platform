class Api::V1::VideosController < Api::V1::BaseController
  def index
    @videos = policy_scope(Video)
  end
end
