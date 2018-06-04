class FansController < ApplicationController
  skip_after_action :verify_policy_scoped, only: :index

  def index
    flash[:notice] = "Wait for it... Your fans are coming soon!" if current_user.sign_in_count == 1
    if params[:query].present?
      sql_query = "youtube_username ILIKE :query"
      @fans = current_user.fans.where(sql_query, query: "%#{params[:query]}%").where.not(channel_id_youtube: current_user.channel_id_youtube).page(params[:page]).per(3*5)
    else
      # .page is from Kaminari gem
      @fans = current_user.fans.where.not(channel_id_youtube: current_user.channel_id_youtube).page(params[:page]).per(3*5)
    end
    respond_to do |format|
      format.html
      format.js
    end
  end

  def show
    @fan = Fan.find(params[:id])
    authorize @fan
    @memo = @fan.memo

    # Retrieving the creator's fan_id for later use
    @creator_fan_id = current_user.fans.find_by(channel_id_youtube: current_user.channel_id_youtube).id
    @comments_by_video = get_comments_by_video_for_a_fan
  end

  def update
    @fan = Fan.find(params[:id])
    authorize @fan
    @memo = @fan.memo
    @memo.update(memo_params)
    redirect_to fan_path(@fan)
  end

  private

  def get_comments_by_video_for_a_fan
    # All comments of a @fan and ordered from last published
    comments_fan = current_user.comments.where(fan_id: @fan.id)

    # All comments of the creator (on all videos)
    comments_creator = current_user.comments.where(fan_id: @creator_fan_id)

    # and fiter conversations with this @fan
    # => For each creator comment, we have to check if the fan is in the discussion
    # if yes we add up this creator comment to the 'comments' variable
    comments = comments_fan.to_a
    comments_creator.each do |comment_creator|
      comments_fan.each do |comment_fan|
        if comment_fan.top_level_comment_id_youtube == comment_creator.top_level_comment_id_youtube
          comments.push(comment_creator)
          break
        end
      end
    end
    comments = comments.sort_by{ |comment| (comment.published_at.to_i) }

    # comments is grouped in a hash by video_id and reordered depending on the last comment date
    comments_by_video = comments.group_by { |comment| comment.video_id }.sort_by { |video_id, comments| -(comments.last.published_at.to_i) }
    return comments_by_video
  end

  def memo_params
    params.require(:comment).permit(:content, :published_at, :video_id)
  end
end


