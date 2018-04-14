class Platform < ApplicationRecord
	has_many :platform_users
	has_many :users, through: :platform_users
	has_many :activities, as: :storable
end
