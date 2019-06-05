# frozen_string_literal: true

class Api::CommitsController < ApiController
  before_action :fetch_repo

  def index
    limit = (params[:limit] || 50).to_i
    sort_direction = VALID_SORT_DIRECTIONS[params[:sort_direction]]

    commits = @repo.commits.limit(limit).reorder(id: sort_direction)
    commits = commits.unverified if params[:filter] == "unverified"
    commits = commits.verified if params[:filter] == "verified"
    commits = commits.where(deploy_status: "succeeded") if params[:deployed]

    render json: { status: "success", commits: commits }
  end

  private

    def fetch_repo
      @repo = Repo.find(params[:repo_id])
    end
end
