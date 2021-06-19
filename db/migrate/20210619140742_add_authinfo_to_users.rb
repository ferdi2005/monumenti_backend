class AddAuthinfoToUsers < ActiveRecord::Migration[6.1]
  def change
    ActiveRecord::Base.connection.execute("CREATE EXTENSION hstore;")
    add_column :users, :authinfo, :hstore
  end
end
