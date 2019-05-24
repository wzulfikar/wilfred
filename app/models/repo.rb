# frozen_string_literal: true

require "active_support"
require "digest/md5"

class Repo < ActiveRecord::Base
  attr_accessible :organization, :name, :branch, :github_webhooks_setup

  belongs_to :owner, class_name: "User"
  has_many :commits
  has_many :users

  def full_name
    "#{organization}/#{name}"
  end

  def full_name_verbose
    "#{organization} / #{name}"
  end

  def setup_github_webhooks
    begin
      owner.github.create_hook(full_name, "web",
        {
          url: Rails.application.routes.url_helpers.github_push_webhook_url,
          content_type: "json"
        },
        {
          events: ["push"],
          active: true
        }
      )
    rescue Octokit::UnprocessableEntity
      Rails.logger.info("hook already exists on github")
    end
    update_attributes!(github_webhooks_setup: true)
  end

  def backfill_commit_history
    owner.github.commits(full_name).each do |commit|
      next unless Commit.find_by_sha1(commit.sha).nil?
      compare_status = owner.github.compare(full_name, branch, commit.sha).status
      next unless ["behind", "identical"].include?(compare_status)

      self.commits.create(
        created_at: commit.commit.author.date,
        message: commit.commit.message,
        email: commit.commit.author.email,
        author_name: commit.commit.author.name,
        sha1: commit.sha
      )
    end
  end
end
