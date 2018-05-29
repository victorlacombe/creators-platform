class FansController < ApplicationController
  def index
    @fans = scope_policy(Fan)
  end

  def show
    @fan = #define @fan as a specific element of the youtubeAPI
    authorize @fan
  end
end
