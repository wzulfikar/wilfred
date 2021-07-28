# frozen_string_literal: true

class Commit < ActiveRecord::Base
  include ActionView::Helpers::DateHelper

  belongs_to :repo

  validates :deploy_status, inclusion: { in: [nil, "started", "failed", "succeeded"] }

  default_scope { order(created_at: :desc) }
  scope :failed, -> { where(state: "failed") }
  scope :unchecked, -> { where(state: nil) }
  scope :verified, -> { where(state: "verified") }
  scope :unverified, -> { where("commits.state != 'verified' or commits.state is null") }

  def formatted_sha1
    sha1[0..6]
  end

  def formatted_timestamp
    time_ago_in_words(created_at)
  end

  def update_deploy_status(status)
    update_attributes!(deploy_status: status)
    return unless deploy_status == "succeeded"
    notify_user_to_verify(User.first, "Your commit, %s (%s), is now on staging." % [formatted_sha1, message])
    notify_github_on_successful_deployment
  end

  def notify_user_to_verify(user, slack_message)
    slack_username = User.find_by_email(email).try(:slack_username)

    if slack_username.present?
      Rails.logger.info("saying to #{slack_username}: #{slack_message}")
      user.slack.chat_postMessage(channel: slack_username, text: slack_message, username: "Wilfred", as_user: false)
    end
  end

  def notify_github_on_successful_deployment
    commenter = User.github_bot || User.find_by_email(email) || User.first
    pr = associated_pull_request
    commenter.post_to_github_issue(pr.number, "This PR is now on staging.")
  end

  def associated_pull_request
    User.first.github.get("repos/#{repo.full_name}/commits/#{sha1}/pulls", accept: "application/vnd.github.groot-preview+json").first
  end

  def remindable?
    User.find_by_email(email).try(:slack_username).present?
  end

  def github_url
    "https://github.com/#{repo.full_name}/commit/#{sha1}"
  end

  def to_html
    "<a href=\"#{github_url}\">#{formatted_sha1}</a> (#{message})"
  end

  def author_gravatar_url
    "https://www.gravatar.com/avatar/#{Digest::MD5.hexdigest(email)}"
  end
end
