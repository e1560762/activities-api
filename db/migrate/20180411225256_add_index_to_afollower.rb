class AddIndexToAfollower < ActiveRecord::Migration[5.1]
  def up
  	add_index :afollowers, [:user_id, :follower_id], unique: true
  end

  def remove
  	remove_index :afollowers, [:user_id, :follower_id]
  end
end
