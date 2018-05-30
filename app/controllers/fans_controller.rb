class FansController < ApplicationController
  def index
    @fans = policy_scope(Fan)
  end

  # def create_fan
  #   @fan = Fan.new(API info)
  #   @memo = Memo.create
  #   @fan.memo = memo
  #   authorize @fan
  #   authorize @memo
  # end

  def show
    @fan = Fan.find(params[:id])
    @memo = @fan.memo
    authorize @fan
    authorize @memo
  end

  def update
    @fan = Fan.find(params[:id])
    @memo = @fan.memo
    authorize @fan
    authorize @memo
    @memo.update(memo_params)
    redirect_to fan_path(@fan)
  end

  private

  def memo_params
    params.require(:memo).permit(:content)
  end
end


