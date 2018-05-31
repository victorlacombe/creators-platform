class Api::V1::MemosController < Api::V1::BaseController
  def index
    @memos = policy_scope(Memo)
  end
end
