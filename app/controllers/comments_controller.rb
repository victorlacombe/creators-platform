class CommentsController < ApplicationController
  def index
    @comments = Comment.all
  end

  def find
    @fan = Fan.find(params[:id])
    authorize @fan
    @comments = Comment.where(fan_id: @fan)
    authorize @comments
    @comment = Comment.find(params[:id])
    authorize @comment
    @videos = policy_scope(Video).where(video_id_youtube: @comment))
    authorize videos
  end

  private

  def memo_params
      params.require(:comment).permit(:content, :published_at, :video_id)
  end
end
