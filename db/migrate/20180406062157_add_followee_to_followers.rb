class AddFolloweeToFollowers < ActiveRecord::Migration[5.1]
  def change
    add_column :followers, :followee, :integer
  end
end
