class CreateAusers < ActiveRecord::Migration[5.1]
  def change
    create_table :ausers do |t|
      t.string :name

      t.timestamps
    end
  end
end
