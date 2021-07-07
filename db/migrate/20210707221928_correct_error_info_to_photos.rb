class CorrectErrorInfoToPhotos < ActiveRecord::Migration[6.1]
  def change
    rename_column :photos, :erorrinfo, :errorinfo
  end
end
