class AddDeployStatusToCommits < ActiveRecord::Migration
  def change
    add_column :commits, :deploy_status, :string
  end
end
