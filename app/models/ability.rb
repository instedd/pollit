class Ability
  include CanCan::Ability

  def initialize(user)
    if user
        can :manage, Poll, :owner_id => user.id
    end
  end
end
