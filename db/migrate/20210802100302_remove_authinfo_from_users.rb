class RemoveAuthinfoFromUsers < ActiveRecord::Migration[6.1]
  def change
    remove_column :users, :authinfo, :hstore
  end
end
