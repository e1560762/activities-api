class Follower < ApplicationRecord
	belongs_to :user
	belongs_to :followee, class_name: "User"
	has_many :activities, as: :storable
	validates :user, uniqueness: {scope: :followee}
end
