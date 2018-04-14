class AddColumnSizeActivityHistories < ActiveRecord::Migration[5.1]
  def change
  	add_column :activity_histories, :size, :integer
  end
end
