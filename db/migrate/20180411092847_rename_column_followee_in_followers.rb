class RenameColumnFolloweeInFollowers < ActiveRecord::Migration[5.1]
  def change
  	rename_column :followers, :followee, :followee_id
  end
end
