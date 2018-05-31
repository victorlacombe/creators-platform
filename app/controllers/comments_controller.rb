class CommentsController < ApplicationController
  def index
    @comments = Comment.all
  end

  def find
    @fan = Fan.find(params[:id])
    comments = Comment.where(fan_id: @fan)
    @comment = Comment.find(params[:id])
    videos = Video.where(video_id_youtube: @comment)
  end

  private

  def memo_params
      params.require(:comment).permit(:content, :published_at, :video_id)
  end
end
