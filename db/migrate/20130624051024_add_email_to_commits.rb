class AddEmailToCommits < ActiveRecord::Migration
  def change
    add_column :commits, :email, :string
  end
end
