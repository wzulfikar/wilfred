class AddSlackAccessTokenToUsers < ActiveRecord::Migration
  def change
    add_column :users, :slack_access_token, :string
  end
end
