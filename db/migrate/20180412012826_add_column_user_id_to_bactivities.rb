class AddColumnUserIdToBactivities < ActiveRecord::Migration[5.1]
  def up
  	add_column :bactivities, :user_id, :integer
  	add_index :bactivities, :user_id
  end

  def down
  	remove_index :bactivities, name: "index_bactivities_on_user_id"
  	remove_column :bactivities, :user_id
  end
end
