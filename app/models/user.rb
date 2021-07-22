# frozen_string_literal: true

class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable

  attr_accessible :email, :password, :password_confirmation, :remember_me,
                  :name, :username, :slack_username, :repo_id, :github_access_token, :slack_access_token

  belongs_to :repo

  def self.github_bot
    User.find_by_username(ENV["GH_BOT_USERNAME"]) if ENV["GH_BOT_USERNAME"].present?
  end

  def password_required?
    false
  end

  def email_required?
    false
  end

  def incomplete?
    repo.nil?
  end

  def github
    Octokit::Client.new(access_token: github_access_token)
  end

  def slack
    Slack::Web::Client.new(token: slack_access_token)
  end

  def notify_to_deploy
    return unless slack_username.present?
    slack_message = "All commits have been verified! <@#{slack_username}>, could you please deploy?"
    Rails.logger.info("saying to slack room: #{slack_message}")
    slack.chat_postMessage(channel: ENV["SLACK_ROOM"], text: slack_message, username: "Wilfred", as_user: false)
  end
end
