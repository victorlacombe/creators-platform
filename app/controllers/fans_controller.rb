class FansController < ApplicationController
  def index
    @fans = policy_scope(Fan)
  end

  def show
    @fan = Fan.find(params[:id])
    authorize @fan
  end
end
