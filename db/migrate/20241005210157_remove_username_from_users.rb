class RemoveUsernameFromUsers < ActiveRecord::Migration[7.2]
  def change
    remove_column :users, :username, :string
  end
end
