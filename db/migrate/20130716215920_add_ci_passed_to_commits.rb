class AddCiPassedToCommits < ActiveRecord::Migration
  def change
    add_column :commits, :ci_passed, :boolean
  end
end
