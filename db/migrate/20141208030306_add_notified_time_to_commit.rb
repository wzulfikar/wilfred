class AddNotifiedTimeToCommit < ActiveRecord::Migration
  def change
    add_column :commits, :notified_at, :datetime
  end
end
