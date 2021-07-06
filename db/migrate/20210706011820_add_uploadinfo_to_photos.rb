class AddUploadinfoToPhotos < ActiveRecord::Migration[6.1]
  def change
    add_column :photos, :canonicaltitle, :string
    add_column :photos, :descriptionurl, :string
    add_column :photos, :url, :string
    add_column :photos, :sha1, :string
  end
end
