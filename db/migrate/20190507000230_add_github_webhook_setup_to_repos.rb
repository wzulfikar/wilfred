class AddGithubWebhookSetupToRepos < ActiveRecord::Migration
  def change
    add_column :repos, :github_webhook_setup, :boolean
  end
end
