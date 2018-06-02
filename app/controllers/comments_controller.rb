class CommentsController < ApplicationController
  def update
    @comment = Comment.find(params[:id])
    authorize @comment
    @comment.is_pinned = params[:is_pinned] if params[:is_pinned] == "true"
    @comment.is_pinned = params[:is_pinned] if params[:is_pinned] == "false"
    @comment.save
    redirect_to fan_path(@comment.fan_id)
  end
end
