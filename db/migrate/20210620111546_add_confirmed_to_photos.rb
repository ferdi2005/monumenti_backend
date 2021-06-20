class AddConfirmedToPhotos < ActiveRecord::Migration[6.1]
  def change
    add_column :photos, :confirmed, :boolean, default: false
  end
end
