class DropTableActivities < ActiveRecord::Migration[5.1]
  def change
  	drop_table :activities
  	sleep(30.seconds)
  	create_table :activities do |t|
      t.string :name
      t.integer :user_id
      t.references :storable, polymorphic: true, index: true
      t.timestamps
    end
    sleep(10.seconds)
  	add_index :activities, :user_id
  end
end
