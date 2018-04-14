class DropExperimemtalTables < ActiveRecord::Migration[5.1]
  def change
  	drop_table :afollowers
  	drop_table :ausers
  	drop_table :bactivities
  end
end
