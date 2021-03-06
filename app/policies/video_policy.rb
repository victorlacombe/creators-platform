class VideoPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.all
    end
  end

  def find_video_owner?
    record.user == user
  end
end
