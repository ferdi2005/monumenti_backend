class AddAuthinfoCiphertextToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :authinfo_ciphertext, :text
  end
end
