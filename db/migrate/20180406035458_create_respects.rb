class CreateRespects < ActiveRecord::Migration[5.1]
  def change
    create_table :respects do |t|

      t.timestamps
    end
  end
end
