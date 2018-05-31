class FansController < ApplicationController
  def index
    if params[:query].present?
      sql_query = "youtube_username ILIKE :query"
      @fans = policy_scope(Fan.where(sql_query, query: "%#{params[:query]}%"))
    else
      @fans = policy_scope(Fan)
    end
  end

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

  def avatar
    @fan.profile_picture_url.gsub(/\/s28-/, “/s300-“)
  end

  private

  def memo_params
    params.require(:memo).permit(:content)
  end

  def memo_params
    params.require(:comment).permit(:content, :published_at, :video_id)
  end
end


