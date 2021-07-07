class AddErrorinfoToPhotos < ActiveRecord::Migration[6.1]
  def change
    add_column :photos, :erorrinfo, :string
  end
end
