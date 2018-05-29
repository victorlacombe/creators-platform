class FansController < ApplicationController
  def index
    @fans = policy_scope(Fan)
  end

  def show
    @fan = #define @fan as a specific element of the youtubeAPI
    authorize @fan
  end
end
