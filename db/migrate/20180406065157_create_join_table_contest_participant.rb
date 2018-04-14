class CreateJoinTableContestParticipant < ActiveRecord::Migration[5.1]
  def change
    create_join_table :contests, :users, table_name: :contest_participant do |t|
      # t.index [:contest_id, :user_id]
      # t.index [:user_id, :contest_id]
    end
  end
end
