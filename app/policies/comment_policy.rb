class CommentPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.all
    end
  end

  def find
    record.user == user
  end

  def update?
    record.video.user == user
  end
end
