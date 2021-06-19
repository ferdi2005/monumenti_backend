class AddAuthinfoToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :authinfo, :hstore
  end
end
