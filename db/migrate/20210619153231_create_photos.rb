class CreatePhotos < ActiveRecord::Migration[6.1]
  def change
    create_table :photos do |t|
      t.references :user, null: false, foreign_key: true
      t.boolean :wlm, default: false

      t.timestamps
    end
  end
end
