class CreateActivities < ActiveRecord::Migration[5.1]
  def change
    create_table :activities do |t|
      t.string :activity_type
      t.string :activity_table_key
      t.integer :activity_record_id
      t.string :parent_table_key
      t.integer :parent_id
      t.references :user, foreign_key: true

      t.timestamps
    end
      add_index :activities, :user_id
      add_index :activities, :id
  end
end
