class Api::V1::CommentsController < Api::V1::BaseController
  def index
    @comments = policy_scope(Comment)
  end
end
