class AddSha1ToCommits < ActiveRecord::Migration
  def change
    add_column :commits, :sha1, :string
  end
end
