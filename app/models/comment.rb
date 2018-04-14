class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :post
  has_many :activities, as: :storable
end
