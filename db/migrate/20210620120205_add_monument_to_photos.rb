class AddMonumentToPhotos < ActiveRecord::Migration[6.1]
  def change
    add_column :photos, :monument, :string
  end
end
