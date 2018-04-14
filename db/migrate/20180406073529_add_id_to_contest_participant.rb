class AddIdToContestParticipant < ActiveRecord::Migration[5.1]
  def change
  	add_column :contest_participant, :id, :serial, null: false, unique: true
  end
end
