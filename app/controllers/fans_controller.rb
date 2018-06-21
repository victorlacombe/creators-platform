class FansController < ApplicationController
  skip_after_action :verify_policy_scoped, only: :index

  def index
    flash[:notice] = "Wait for it... Your fans are coming soon!" if current_user.sign_in_count == 1

    #@all_fans = User.includes(fans: :comments).find(current_user.id).fans.where.not(channel_id_youtube: current_user.channel_id_youtube)
    @all_fans = current_user.fans.where('fans.channel_id_youtube != ?', current_user.channel_id_youtube)

    if params[:query].present?
      sql_query = "youtube_username ILIKE :query"
      @fans_list = @all_fans.where(sql_query, query: "%#{params[:query]}%").page(params[:page]).per(4*3)
      @fans = @fans_list.includes(:comments) # not sure if it will only loads comments for the fans_list or for all fans... to be checked!
    else
      # .page is from Kaminari gem
      @fans_list = @all_fans.page(params[:page]).per(4*3)
      @fans = @fans_list.includes(:comments)
      respond_to do |format|
        format.html do
          # For excluding creator in stats
          # creator_in_fans_table = Fan.find_by_channel_id_youtube(current_user.channel_id_youtube)

          @top_fans_list = top_fans_list # We don't need to call the full function top_fans, as we don't want to load the memory. This is just to get the stat number.
          @new_fans_list = new_fans_list
          @returning_fans_list = returning_fans_list
        end
        format.js
      end
    end
  end

  def show
    @fan = Fan.find(params[:id])
    authorize @fan
    @memo = Memo.find_by(user_id: current_user, fan_id: @fan)

    # Retrieving the creator's fan_id for later use
    @creator_fan_id = current_user.fans.find_by(channel_id_youtube: current_user.channel_id_youtube).id
    @comments_by_video = get_comments_by_video_for_a_fan
  end

  def update
    @fan = Fan.find(params[:id])
    authorize @fan
    @memo = Memo.find_by(user_id: current_user, fan_id: @fan)
    @memo.update(memo_params)
    redirect_to fan_path(@fan)
  end

  def top_fans
    skip_authorization
    @fan_type_name = "top fan"
    @definition_header = "They are loyal to you and are still active in the last 2 months"
    # We find all fans but don't load any comments in memory (we use joins).
    #Loading it direclty in memory is not useful as comments are being filtered here and we wouldn't get all comments.
    @top_fans_list = top_fans_list

    # Load all comments in memory for each of the top fans found above.
    @top_fans_with_all_comments = current_user.fans
                                              .eager_load(:comments)
                                              .where(id: @top_fans_list.to_a)
                                              .group('fans.id', 'comments.id')
                                              #.order('count(comments.id) DESC') # Can't make this order works..

    @top_fans_with_all_comments = @top_fans_with_all_comments.sort_by { |fan| -fan.comments.length } # Order using ruby sort_by
    @size = @top_fans_with_all_comments.length
    @fans = Kaminari.paginate_array(@top_fans_with_all_comments).page(params[:page]).per(4*3)
    ajax_infinite_scroll
  end

  def new_fans
    skip_authorization
    @fan_type_name = "new fan"
    @definition_header = "They wrote their first comment(s) this month"

    # Same logic as top_fans
    @new_fans_list = new_fans_list
    @new_fans_with_all_comments = current_user.fans
                                              .eager_load(:comments)
                                              .where(id: @new_fans_list.to_a)
                                              #.group('fans.id', 'comments.id')
                                              #.order('count(comments.id) DESC') # Can't make this order works..
    @new_fans_with_all_comments = @new_fans_with_all_comments.sort_by { |fan| -fan.comments.length }
    @size = @new_fans_with_all_comments.length
    @fans = Kaminari.paginate_array(@new_fans_with_all_comments).page(params[:page]).per(4*3)
    ajax_infinite_scroll
  end

  def returning_fans
    skip_authorization
    @fan_type_name = "returning fan"
    @definition_header = "They are new fans (or were loyal) and have just returned to your channel this month"
    # Same logic as top_fans
    @returning_fans_list = returning_fans_list
    @returning_fans_with_all_comments = current_user.fans
                                              .eager_load(:comments)
                                              .where(id: @returning_fans_list.to_a)
                                              .group('fans.id', 'comments.id')
                                              #.order('count(comments.id) DESC') # Can't make this order works..
    @returning_fans_with_all_comments = @returning_fans_with_all_comments.sort_by { |fan| -fan.comments.length }
    @size = @returning_fans_with_all_comments.length
    @fans = Kaminari.paginate_array(@returning_fans_with_all_comments).page(params[:page]).per(4*3)
    ajax_infinite_scroll
  end

  def inactive_fans
    skip_authorization

    cache_key = "test"
    # Test caching
    Rails.cache.fetch("#{cache_key}", expires_in: 10.minutes) do
      @fan_type_name = "inactive fan"
      @definition_header = "They haven't participated in the last 2 months"
      # Same logic as top_fans
      @inactive_fans_list = inactive_fans_list
      @inactive_fans_with_all_comments = current_user.fans
                                                .eager_load(:comments)
                                                .where(id: @inactive_fans_list.to_a)
                                                .group('fans.id', 'comments.id')
                                                #.order('count(comments.id) DESC') # Can't make this order works..
      @inactive_fans_with_all_comments = @inactive_fans_with_all_comments.sort_by { |fan| -fan.comments.length }
      @size = @inactive_fans_with_all_comments.length
      @fans = Kaminari.paginate_array(@inactive_fans_with_all_comments).page(params[:page]).per(4*3)
    end

    ajax_infinite_scroll
  end

  private

  def ajax_infinite_scroll
    respond_to do |format|
      format.html
      format.js { render 'index.js.erb'}
    end
  end

  def top_fans_list
    min_last_activity_date = 2.month
    min_comment = 0
    # People who have commented in the last x.month
    # We find all fans but don't load any comments in memory (we use joins).
    #Loading it direclty in memory is not useful as comments are being filtered here and we wouldn't get all comments.

    # ==========================================
    # HAVE TO ADD EXPLICITLY THAT THE COMMENTS BELONG TO THE CURRENT_USER ALSO...? or is it included in current_user? TO BE CHECKED
    # ==========================================

    return current_user.fans # Select all fans from current user
                        .joins(:comments)
                        .where('comments.published_at > ? AND fans.channel_id_youtube != ?', Date.today - min_last_activity_date, current_user.channel_id_youtube)
                        .having('count(comments.published_at) > ?', min_comment)
                        .group("fans.id")
                        .distinct # to return unque object
  end

  def new_fans_list
    min_last_activity_date = 1.month
    arrived_x_month_ago = 1.month
    min_comment = 0

    return current_user.fans # People who have commented this month
                        .joins(:comments)
                        .where('comments.published_at > ? AND fans.channel_id_youtube != ?', Date.today - min_last_activity_date, current_user.channel_id_youtube)
                        .having('count(comments.published_at) > ?', min_comment)
                        .group("fans.id")
                        .distinct -
           current_user.fans # but never before this month!
                       .joins(:comments)
                       .where('comments.published_at < ? AND fans.channel_id_youtube != ?', Date.today - arrived_x_month_ago, current_user.channel_id_youtube)
                       .having('count(comments.published_at) > ?', 0)
                       .group("fans.id")
                       .distinct

  end

  def inactive_fans_list
    min_last_activity_date = 2.month
    min_comment = 0

    return current_user.fans.where('fans.channel_id_youtube != ?', current_user.channel_id_youtube) - # Everyone
           current_user.fans # but those who haven't commented for the last 2 months
                      .joins(:comments)
                      .where('comments.published_at > ? AND fans.channel_id_youtube != ?', Date.today - min_last_activity_date, current_user.channel_id_youtube)
                      .having('count(comments.published_at) > ?', min_comment)
                      .group("fans.id")
                      .distinct
  end

  def returning_fans_list
    min_last_activity_date = 1.month
    min_last_sleepy_date = 3.month #slept at least between 3.month and 1.month ago (for 2 months)
    arrived_x_month_ago = 2.month
    min_comment = 0
    min_comments_several = 1

                      # -- People who were loyal, slept for 2 months, and are back!
    return (current_user.fans # People who have commented this month
                        .joins(:comments)
                        .where('comments.published_at > ? AND fans.channel_id_youtube != ?', Date.today - min_last_activity_date, current_user.channel_id_youtube)
                        .having('count(comments.published_at) > ?', min_comment)
                        .group("fans.id")
                        .distinct -
           current_user.fans # and who didn't commented last month
                        .joins(:comments)
                        .where('comments.published_at < ? AND comments.published_at > ? AND fans.channel_id_youtube != ?', Date.today - min_last_activity_date, Date.today - min_last_sleepy_date, current_user.channel_id_youtube)
                        .having('count(comments.published_at) > ?', min_comment)
                        .group("fans.id")
                        .distinct &
           current_user.fans # and yet commented months before
                        .joins(:comments)
                        .where('comments.published_at < ? AND fans.channel_id_youtube != ?', Date.today - min_last_sleepy_date, current_user.channel_id_youtube)
                        .having('count(comments.published_at) > ?', min_comment)
                        .group("fans.id")
                        .distinct) +

                        # -- We also add to this list newly arrived fans who commented several times this month
          (current_user.fans # People who have commented this month
                        .joins(:comments)
                        .where('comments.published_at > ? AND fans.channel_id_youtube != ?', Date.today - min_last_activity_date, current_user.channel_id_youtube)
                        .having('count(comments.published_at) > ?', min_comments_several)
                        .group("fans.id") -
           current_user.fans # but never before this month!
                       .joins(:comments)
                       .where('comments.published_at < ? AND fans.channel_id_youtube != ?', Date.today - min_last_activity_date, current_user.channel_id_youtube)
                       .having('count(comments.published_at) > ?', 0)
                       .group("fans.id")
                       .distinct) +

                        # -- We also add to this list newly arrived fans who started commented last month, and came back
          ((current_user.fans # People who have commented this month
                        .joins(:comments)
                        .where('comments.published_at > ? AND fans.channel_id_youtube != ?', Date.today - min_last_activity_date, current_user.channel_id_youtube)
                        .having('count(comments.published_at) > ?', min_comment)
                        .group("fans.id")
                        .distinct &
          current_user.fans # and have also commented last month
                        .joins(:comments)
                        .where('comments.published_at < ? AND comments.published_at > ? AND fans.channel_id_youtube != ?', Date.today - min_last_activity_date, Date.today - arrived_x_month_ago, current_user.channel_id_youtube)
                        .having('count(comments.published_at) > ?', min_comment)
                        .group("fans.id")
                        .distinct) -
           current_user.fans # but never before 2 month/arrival date!
                       .joins(:comments)
                       .where('comments.published_at < ? AND fans.channel_id_youtube != ?', Date.today - arrived_x_month_ago, current_user.channel_id_youtube)
                       .having('count(comments.published_at) > ?', 0)
                       .group("fans.id")
                       .distinct)

  end

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


# Edward stuffs
# fans_with_one_to_three_comment_before_last_month = Comment.joins(fan: :comments, video: :user)
#                                                     .where("users.id = ? AND comments.published_at < ?", current_user.id, Date.today - 1.month)
#                                                     .having("count(comments.id) < 4")
#                                                     .group(:fan)
#                                                     .count
#                                                     .keys

# fans_with_at_least_one_comments_during_last_month = Comment.joins(fan: :comments, video: :user).where("users.id = ? AND comments.published_at > ?", current_user.id, Date.today - 1.month).having("count(comments.id) > 0").group(:fan).count.keys
# all_time_fans = Comment.joins(fan: :comments, video: :user).where("users.id = ?", current_user).having("count(comments.id) > 0").group(:fan).count.keys
# fans_who_commented_during_last_month = Comment.joins(fan: :comments, video: :user).where("users.id = ? AND comments.published_at > ?", current_user, Date.today - 2.month).having("count(comments.id) > 0").group(:fan).count.keys


#Hash {fan => comment_count}
# @last_month_new_fans = Comment.joins(fan: :comments, video: :user).where("users.id = ? AND comments.published_at > ? AND NOT comments.published_at < ?", current_user.id, Date.today - 1.month, Date.today - 1.month).group(:fan).count


# Old top fans stuffs
# Old - Gab Attempt (buggy)
# creator_in_fans_table = Fan.find_by_channel_id_youtube(current_user.channel_id_youtube)
# all_time_fans = Comment.joins(fan: :comments, video: :user)
#                 .where("users.id = ?", current_user)
#                 .having("count(comments.id) > 0")
#                 .order("COUNT(comments.id) DESC")
#                 .group(:fan)
#                 .count
#                 .keys
# fans_who_commented_during_last_month = Comment.joins(fan: :comments, video: :user).where("users.id = ? AND comments.published_at > ?", current_user, Date.today - 2.month).having("count(comments.id) > 0").group(:fan).count.keys
# churning_fans = all_time_fans - fans_who_commented_during_last_month
# @top_fans = all_time_fans - churning_fans
# @top_fans.delete(creator_in_fans_table)

# Retrying Active record # Attemp 1 Julien (buggy can't get all comments)
# @top_fans = current_user.fans # Select all fans from current user
#             .includes(:comments) # Includes comments, so that it can be saved in memory and avoid N+1 queries
#             .select('fans.youtube_username', 'fans.profile_picture_url', 'fans.channel_id_youtube', 'comments.published_at') # Select only data we need
#             .references(:comments) # Join comments so that we can do .where on it | works in parallel with .includes
#             .where('comments.published_at > ? AND fans.channel_id_youtube != ?', Date.today - min_last_activity_date, current_user.channel_id_youtube)
#             .having('count(comments.published_at) > ?', min_comment)
#             .group('fans.id', 'fans.youtube_username', 'fans.profile_picture_url', 'fans.channel_id_youtube', 'comments.id', 'comments.published_at')
#             .distinct # be sure that all results are unique




# Old new fans stuffs
 # fans_with_zero_comment_before_last_month = Comment.joins(fan: :comments, video: :user).where("users.id = ? AND comments.published_at < ?", current_user.id, Date.today - 1.month).having("count(comments.id) = 0").group(:fan).count.keys
    # fans_with_at_least_one_comment_this_month = Comment.joins(fan: :comments, video: :user).where("users.id = ? AND comments.published_at > ?", current_user.id, Date.today - 1.month).group(:fan).count.reject { |k, v| v < 1 }

    # @old_fans = Fan.joins(:comments, memo: :user).where("users.id = ? AND comments.published_at < ?", current_user.id, Date.today - 1.month).pluck(:id)
    # @last_month_new_fans = Fan.joins(:comments).where.not(id: @old_fans).order("comments.published_at DESC").select("fans.*, comments.published_at, count(comments.id) as comments_count").group("fans.id, comments.published_at").uniq

    # @last_month_new_fans.reject! { |fan| fan.channel_id_youtube == current_user.channel_id_youtube }
