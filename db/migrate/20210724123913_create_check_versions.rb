class CreateCheckVersions < ActiveRecord::Migration[6.1]
  def change
    create_table :check_versions do |t|
      t.string :uuid
      t.string :old_version
      t.string :app_version
      t.string :device_name
      t.string :os_version 
      t.string :os
      t.string :model
      t.boolean :updated

      t.timestamps
    end
  end
end
