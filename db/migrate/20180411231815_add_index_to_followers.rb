class AddIndexToFollowers < ActiveRecord::Migration[5.1]
  def up
  	remove_index :followers, name: "index_followers_on_user_id"
  	add_index :followers, [:user_id, :followee_id], unique: true
  end

  def down
  	add_index :followers, :user_id
  	remove_index :followers, name: "index_followers_on_user_id_and_followee_id"
  end
end
