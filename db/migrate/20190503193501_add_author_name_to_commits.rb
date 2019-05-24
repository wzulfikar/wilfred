class AddAuthorNameToCommits < ActiveRecord::Migration
  def change
    add_column :commits, :author_name, :string
  end
end
