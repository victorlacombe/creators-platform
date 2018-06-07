class FansController < ApplicationController
  skip_after_action :verify_policy_scoped, only: :index

  def index
    flash[:notice] = "Wait for it... Your fans are coming soon!" if current_user.sign_in_count == 1
    if params[:query].present?
      sql_query = "youtube_username ILIKE :query"
      @fans = User.includes(fans: :comments).find(current_user.id).fans.where(sql_query, query: "%#{params[:query]}%").where.not(channel_id_youtube: current_user.channel_id_youtube).page(params[:page]).per(4*3)
    else
      # .page is from Kaminari gem
      @fans = User.includes(fans: :comments).find(current_user.id).fans.where.not(channel_id_youtube: current_user.channel_id_youtube).page(params[:page]).per(4*3)

      respond_to do |format|
        format.html do
          # For excluding creator in stats
          creator_in_fans_table = Fan.find_by_channel_id_youtube(current_user.channel_id_youtube)

          #Fan ::ActiveRecord_AssociationRelation || We already exclude the creator in request
          @all_time_fans = User.includes(fans: :comments).find(current_user.id).fans.where.not(channel_id_youtube: current_user.channel_id_youtube)

          #Hash {fan => comment_count}
          # @last_month_new_fans = Comment.joins(fan: :comments, video: :user).where("users.id = ? AND comments.published_at > ? AND NOT comments.published_at < ?", current_user.id, Date.today - 1.month, Date.today - 1.month).group(:fan).count
          new_fans
          top_fans
          new_loyal_fans

          # #Arrays
          # fans_with_one_to_three_comment_before_last_month = Comment.joins(fan: :comments, video: :user)
          #                                                     .where("users.id = ? AND comments.published_at < ?", current_user.id, Date.today - 1.month)
          #                                                     .having("count(comments.id) < 4")
          #                                                     .group(:fan)
          #                                                     .count
          #                                                     .keys

          # fans_with_at_least_one_comments_during_last_month = Comment.joins(fan: :comments, video: :user).where("users.id = ? AND comments.published_at > ?", current_user.id, Date.today - 1.month).having("count(comments.id) > 0").group(:fan).count.keys
          # @last_month_new_loyal_fans = fans_with_one_to_three_comment_before_last_month & fans_with_at_least_one_comments_during_last_month

          # #Array
          # all_time_fans = Comment.joins(fan: :comments, video: :user).where("users.id = ?", current_user).having("count(comments.id) > 0").group(:fan).count.keys
          # fans_who_commented_during_last_month = Comment.joins(fan: :comments, video: :user).where("users.id = ? AND comments.published_at > ?", current_user, Date.today - 2.month).having("count(comments.id) > 0").group(:fan).count.keys
          # @churning_fans = all_time_fans - fans_who_commented_during_last_month

          # #Array
          # @top_fans = all_time_fans - @churning_fans

          # #Delete the creator from stats
          # @last_month_new_fans.delete(creator_in_fans_table)
          # @last_month_new_loyal_fans.delete(creator_in_fans_table)
          # @churning_fans.delete(creator_in_fans_table)
          # @top_fans.delete(creator_in_fans_table)
        end
        format.js
      end
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

  def top_fans
    creator_in_fans_table = Fan.find_by_channel_id_youtube(current_user.channel_id_youtube)
    all_time_fans = Comment.joins(fan: :comments, video: :user)
                    .where("users.id = ?", current_user)
                    .having("count(comments.id) > 0")
                    .order("COUNT(comments.id) DESC")
                    .group(:fan)
                    .count
                    .keys

    fans_who_commented_during_last_month = Comment.joins(fan: :comments, video: :user).where("users.id = ? AND comments.published_at > ?", current_user, Date.today - 2.month).having("count(comments.id) > 0").group(:fan).count.keys
    churning_fans = all_time_fans - fans_who_commented_during_last_month
    @top_fans = all_time_fans - churning_fans
    @top_fans.delete(creator_in_fans_table)
    skip_authorization
  end

  def new_fans
    # fans_with_zero_comment_before_last_month = Comment.joins(fan: :comments, video: :user).where("users.id = ? AND comments.published_at < ?", current_user.id, Date.today - 1.month).having("count(comments.id) = 0").group(:fan).count.keys
    # fans_with_at_least_one_comment_this_month = Comment.joins(fan: :comments, video: :user).where("users.id = ? AND comments.published_at > ?", current_user.id, Date.today - 1.month).group(:fan).count.reject { |k, v| v < 1 }

    @old_fans = Fan.joins(:comments, memo: :user).where("users.id = ? AND comments.published_at < ?", current_user.id, Date.today - 1.month).pluck(:id)
    @last_month_new_fans = Fan.joins(:comments).where.not(id: @old_fans).order("comments.published_at DESC").select("fans.*, comments.published_at, count(comments.id) as comments_count").group("fans.id, comments.published_at").uniq

    @last_month_new_fans.reject! { |fan| fan.channel_id_youtube == current_user.channel_id_youtube }
    skip_authorization
  end

  def sleeping
    creator_in_fans_table = Fan.find_by_channel_id_youtube(current_user.channel_id_youtube)

    all_time_fans = Comment.joins(fan: :comments, video: :user).where("users.id = ?", current_user).having("count(comments.id) > 0").order("COUNT(comments.id) DESC").group(:fan).count.keys
    fans_who_commented_during_last_month = Comment.joins(fan: :comments, video: :user).where("users.id = ? AND comments.published_at > ?", current_user, Date.today - 2.month).having("count(comments.id) > 0").group(:fan).count.keys

    @churning_fans = all_time_fans - fans_who_commented_during_last_month
    @churning_fans.delete(creator_in_fans_table)

    skip_authorization
  end

  def new_loyal_fans
    creator_in_fans_table = Fan.find_by_channel_id_youtube(current_user.channel_id_youtube)
    fans_with_one_to_three_comment_before_last_month = Comment.joins(fan: :comments, video: :user).where("users.id = ? AND comments.published_at < ?", current_user.id, Date.today - 1.month).having("count(comments.id) < 4").group(:fan).count.keys
    fans_with_at_least_one_comments_during_last_month = Comment.joins(fan: :comments, video: :user).where("users.id = ? AND comments.published_at > ?", current_user.id, Date.today - 1.month).having("count(comments.id) > 0").group(:fan).count.keys
    @last_month_new_loyal_fans = fans_with_one_to_three_comment_before_last_month & fans_with_at_least_one_comments_during_last_month
    @last_month_new_loyal_fans.delete(creator_in_fans_table)
    @last_month_new_loyal_fans = @last_month_new_loyal_fans.sort_by  { |fan, count|
      -fan.comments[-1].published_at.to_i
    }
    skip_authorization
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


