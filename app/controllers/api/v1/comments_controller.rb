class Api::V1::CommentsController < Api::V1::BaseController
  def index
    query = params[:query]
    if query
      @comments = policy_scope(Comment).where(fan_id: query)
    else
       @comments = policy_scope(Comment)
    end
  end
end
