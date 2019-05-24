class AddIndexForRepoIdToUsers < ActiveRecord::Migration
  def change
    add_column :users, :repo_id, :integer
    add_index :users, :repo_id
  end
end
