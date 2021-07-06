class AddUploadedToPhotos < ActiveRecord::Migration[6.1]
  def change
    add_column :photos, :uploaded, :bool
  end
end
