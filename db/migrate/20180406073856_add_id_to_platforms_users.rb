class AddIdToPlatformsUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :platforms_users, :id, :serial, null: false, unique: true
  end
end
