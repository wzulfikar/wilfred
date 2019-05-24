class ChangeWebhookToWebhooks < ActiveRecord::Migration
  def change
    rename_column :repos, :github_webhook_setup, :github_webhooks_setup
  end
end
