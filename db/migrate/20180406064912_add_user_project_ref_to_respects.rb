class AddUserProjectRefToRespects < ActiveRecord::Migration[5.1]
  def change
    add_reference :respects, :user, foreign_key: true
    add_reference :respects, :project, foreign_key: true
  end
end
