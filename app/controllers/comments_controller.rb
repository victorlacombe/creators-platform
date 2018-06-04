class CommentsController < ApplicationController
  def update
    @comment = Comment.find(params[:id])
    authorize @comment
    @comment.toggle_is_pinned!
    @comment.save

    # Ajaxification
    respond_to do |format|
      format.html { redirect_to fan_path(@comment.fan_id) }
      format.js  # <-- will render `app/views/comments/update.js.erb`
    end
  end
end
