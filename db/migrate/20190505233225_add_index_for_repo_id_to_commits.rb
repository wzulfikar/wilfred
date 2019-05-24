class AddIndexForRepoIdToCommits < ActiveRecord::Migration
  def change
    add_column :commits, :repo_id, :integer
    add_index :commits, :repo_id
  end
end
