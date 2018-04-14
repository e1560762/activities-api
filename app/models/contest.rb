class Contest < ApplicationRecord
	has_many :contest_participants
	has_many :users, through: :contest_participants
	has_many :activities, as: :storable
end
