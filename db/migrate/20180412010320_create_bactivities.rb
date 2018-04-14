class CreateBactivities < ActiveRecord::Migration[5.1]
  def change
    create_table :bactivities do |t|
      t.string :name
      t.references :recordable, polymorphic: true, index: true
      t.timestamps
    end
  end
end
