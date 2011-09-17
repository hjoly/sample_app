class Micropost < ActiveRecord::Base
  attr_accessible :content

  belongs_to :user

  validates :content, :presence => true, :length => { :maximum => 140 }
  validates :user_id, :presence => true

  default_scope :order => 'microposts.created_at DESC'

  # def self.from_users_followed_by(user)
  #   # # First version:
  #   # # ActiveRecord provides "user.following_ids" which is equivalent to "user.following.map(&:id)"
  #   # # where "[1, 2, 3, 4].map(&:to_s)" is equivalent to "[1, 2, 3, 4].map { |i| i.to_s }"
  #   # following_ids = user.following_ids
  #   # where("user_id IN (#{following_ids}) OR user_id = ?", user)
  #
  #   # 2th Version:
  #   # Translates to "where user_id IN (#{user.following_ids} OR user_id = #{user.id}"
  #   # Note: [1, 2, 3].push(4) = [1, 2, 3, 4]
  #   # Doesn't scale well when user.following_ids' array contains lots of elements
  #   where(:user_id => user.following.push(user))
  # end

  # Final version (via a scope):
  # Return microposts from the users being followed by the given user. We use a lambda to pass a "user" argument.
  # A scope is a Rails method for restricting db selects based on certain conditions.  It can be invoked like: 
  # Micropost.from_users_followed_by(@user).
  scope :from_users_followed_by, lambda { |user| followed_by(user) }

  private

    # Return an SQL condition for users followed by the given user.
    # We include the user's own id as well.
    def self.followed_by(user)
      # # Not efficient: needs to load a potentially big array into memory
      # following_ids = user.following_ids
      #
      # This version is efficient as it arranges for all the set logic to be pushed into the db.
      # See http://pivotallabs.com/users/jsusser/blog/articles/567-hacking-a-subselect-in-activerecord
      # for a fancier way to create a subselect.
      # Note the use of %() which is a string definition replacing the "". It can contain dble quotes an can span many lines.
      following_ids = %(SELECT followed_id FROM relationships WHERE follower_id = :user_id)

      # The following is equivalent to 'where("... OR user_id = ?", user)"
      where("user_id IN (#{following_ids}) OR user_id = :user_id",
            { :user_id => user })
    end
end
