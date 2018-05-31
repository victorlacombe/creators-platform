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


