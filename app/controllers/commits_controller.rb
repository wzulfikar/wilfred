# frozen_string_literal: true

class CommitsController < ApplicationController
  skip_before_filter :verify_authenticity_token
  before_filter :fetch_commit, except: [:index]

  PAST_COMMIT_COUNT = 50

  def index
    return redirect_to onboarding_url if current_user.incomplete?
    return redirect_to onboarding_slack_path if current_user.slack_username.nil?
    prepare_commits
  end

  def remind
    slack_message = "This is a friendly reminder from <@%s> to <%s|verify your commit>, %s (%s), on staging." % [current_user.slack_username, 
                    Rails.application.routes.url_helpers.root_url, @commit.formatted_sha1, @commit.message]

    @commit.notify_user_to_verify(current_user, slack_message)
    prepare_commits
    render_json_success_response
  end

  def verify
    @commit.update_attributes(state: "verified")
    prepare_commits
    current_user.post_to_github_issue(@commit.associated_pull_request.number, "Marked as verified by #{current_user.username}")
    current_user.notify_to_deploy if @unchecked_commits.empty? && @failed_commits.empty?
    render_json_success_response
  end

  def fail
    @commit.update_attributes(state: "failed")
    prepare_commits
    render_json_success_response
  end

  private

    def fetch_commit
      @commit = Commit.find(params[:id])
    end

    def prepare_commits
      @past_commits = current_user.repo.commits.verified.limit(PAST_COMMIT_COUNT).all
      @failed_commits = current_user.repo.commits.failed
      @unchecked_commits = current_user.repo.commits.unchecked
    end

    def render_json_success_response
      render json: {
        success: true,
        html: render_to_string(partial: "commit_content",
                               locals: {
                                  past_commits: @past_commits,
                                  failed_commits: @failed_commits,
                                  unchecked_commits: @unchecked_commits,
                                }
        ) }
    end
end
