class CreateCrashes < ActiveRecord::Migration[6.1]
  def change
    create_table :crashes do |t|
      t.string :uuid
      t.string :data
      t.string :device_name
      t.string :os_version 
      t.string :os
      t.string :model

      t.timestamps
    end
  end
end