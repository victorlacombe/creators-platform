class FansController < ApplicationController
  def index
    @fans = Fan.all
  end

  def show
    @fan = #define @fan as a specific element of
  end
end
