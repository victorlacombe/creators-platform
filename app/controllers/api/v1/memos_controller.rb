class Api::V1::MemosController < Api::V1::BaseController
  def index
    query = params[:query]
    if query
      @memos = policy_scope(Memo).where(id: query)
    else
      @memos = policy_scope(Memo)
    end
  end
end
