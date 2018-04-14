class PlatformUser < ApplicationRecord
	self.table_name = 'platforms_users'
	belongs_to :platform
	belongs_to :user
end