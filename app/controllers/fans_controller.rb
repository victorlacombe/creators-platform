class FansController < ApplicationController
  skip_after_action :verify_policy_scoped, only: :index

  def index
    if params[:query].present?
      sql_query = "youtube_username ILIKE :query"
      @fans = current_user.fans.where(sql_query, query: "%#{params[:query]}%")
    else
      @fans = current_user.fans
    end
  end

  def show
    @fan = Fan.find(params[:id])
    authorize @fan
    @memo = @fan.memo
    @comments_by_video = get_comments_by_video_for_a_fan
  end

  def update
    @fan = Fan.find(params[:id])
    authorize @fan
    @memo = @fan.memo
    @memo.update(memo_params)
    redirect_to fan_path(@fan)
  end

  def comments_count
    @fan = Fan.find(params[:id])
    authorize @fan
    @fan.comments.count
  end

  private

  def get_comments_by_video_for_a_fan
    # All comments of a user filtered by the @fan and ordered from last published
    comments = current_user.comments.where(fan_id: @fan).order(published_at: :desc)
    # comments is grouped in a hash by video_id and reordered depending on the last comment date
    comments_by_video = comments.group_by { |comment| comment.video_id }.sort_by { |video_id, comments| (comments.last.published_at) }
    return comments_by_video
  end

  def memo_params
    params.require(:comment).permit(:content, :published_at, :video_id)
  end
end


