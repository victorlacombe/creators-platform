class Api::V1::FansController < Api::V1::BaseController
  def index

    # select only the beginning of the URL of the image.
    # we can't reconciliate URL with "https://yt3.ggpht.com/-4s0E7QxVNGw/AAAAAAAAAAI/AAAAAAAAAAA/aLmGgWQbOFA/s48-c-k-no-mo-rj-c0xffffff/photo.jpg"
    # we can alony do it with "https://yt3.ggpht.com/-4s0E7QxVNGw/AAAAAAAAAAI/AAAAAAAAAAA/aLmGgWQbOFA/"
    # for the end of the URL is not the same in YouTube website and Youtube Database (through API)
    query = params[:query]
    if query
      @fans = policy_scope(Fan).where("profile_picture_url ILIKE ?", "%#{query}%")
    else
      @fans = policy_scope(Fan)
    end
  end
end
