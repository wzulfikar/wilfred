# frozen_string_literal: true

class UsersController < ApplicationController
  include ApplicationHelper

  skip_before_filter :verify_authenticity_token

  def onboarding
    @organizations = current_user.github.organizations
  end

  def repos
    render json: {
      success: true,
      repositories: current_user.github.organization_repositories(params[:organization], per_page: 100).map(&:name)
    }
  end

  def save_picked_repo
    repo = Repo.find_or_create_by(organization: params[:organization], name: params[:name])
    repo.update_attribute(:owner_id, current_user.id) if repo.owner_id.nil?
    repo.update_attribute(:branch, current_user.github.repository(repo.full_name).default_branch)
    repo.setup_github_webhooks unless repo.github_webhooks_setup?
    repo.backfill_commit_history if repo.commits.empty?

    render json: { success: current_user.update_attribute(:repo_id, repo.id) }
  end
end
