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
    @comments = Comment.where(fan_id: @fan)
    authorize @fan
    authorize @memo
    #authorize @comment
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

  def memo_params
    params.require(:comment).permit(:content, :published_at, :video_id)
  end
end


