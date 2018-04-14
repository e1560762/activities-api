class RemoveForeignKeyFromFollowers < ActiveRecord::Migration[5.1]
  def change
  	remove_foreign_key :followers, :users
  end
end
