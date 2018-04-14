class CreateAfollowers < ActiveRecord::Migration[5.1]
  def change
    create_table :afollowers do |t|
      t.integer :user_id
      t.integer :follower_id

      t.timestamps
    end
  end
end
