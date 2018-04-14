class AddIndexToActivityHistories < ActiveRecord::Migration[5.1]
  def change
    add_index :activity_histories, :created_at
  end
end
