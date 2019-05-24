class AddNotificationsSentToCommit < ActiveRecord::Migration
  def change
    add_column :commits, :notifications_sent, :integer
  end
end
