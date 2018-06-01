class VideoController < ApplicationController
  def index
    @videos = Video.all
  end
end
