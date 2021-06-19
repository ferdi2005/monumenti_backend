class AddAuthorizedToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :authorized, :boolean, default: false
  end
end
