class Respect < ApplicationRecord
	belongs_to :user
	belongs_to :project
	has_many :activities, as: :storable
	validates :user, uniqueness: {scope: :project}
end
