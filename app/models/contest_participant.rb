class ContestParticipant < ApplicationRecord
	self.table_name = "contest_participant"
	belongs_to :contest
	belongs_to :user
end