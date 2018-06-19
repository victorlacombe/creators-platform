class Api::V1::VideosController < Api::V1::BaseController
  def find_video_owner
    query = params[:query]
    @video = Video.where("video_id_youtube ILIKE ?","%#{query}%").first
    authorize @video
    response.headers['Access-Control-Allow-Origin'] = 'chrome-extension://jhonneacdfhalcbcjfhglialbnlnjbpi';
    response.headers['Access-Control-Allow-Credentials'] = 'true';
  end
end
