class AddTestuserToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :testuser, :bool, default: false
  end
end
