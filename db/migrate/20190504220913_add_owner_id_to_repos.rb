class AddOwnerIdToRepos < ActiveRecord::Migration
  def change
    add_column :repos, :owner_id, :integer
    add_index :repos, :owner_id
  end
end
