class RemoveIndexesFromRespects < ActiveRecord::Migration[5.1]
  def up
  	remove_index :respects, name: "index_respects_on_project_id"
  	remove_index :respects, name: "index_respects_on_user_id"
  	add_index :respects, [:user_id, :project_id], unique: true
  end

  def remove
  	add_index :respects, :project_id
  	add_index :respects, :user_id
  	remove_index :respects, name: "index_respects_on_user_id_project_id"
  end
end
