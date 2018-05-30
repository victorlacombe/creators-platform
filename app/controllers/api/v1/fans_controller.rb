class Api::V1::FansController < Api::V1::BaseController
  def index
    @fans = policy_scope(Fan)
  end
end
