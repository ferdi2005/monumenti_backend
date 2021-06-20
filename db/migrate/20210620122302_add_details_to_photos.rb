class AddDetailsToPhotos < ActiveRecord::Migration[6.1]
  def change
    add_column :photos, :title, :string
    add_column :photos, :description, :text
    add_column :photos, :date, :date
  end
end
