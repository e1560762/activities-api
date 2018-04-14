class User < ApplicationRecord
	has_many :contest_participants
	has_many :platform_users
	has_many :contests, through: :contest_participants
	has_many :platforms, through: :platform_users
	has_many :respects
	has_many :posts
	has_many :comments

	def followers
		return Follower.where(user_id: self.id)
	end

end
