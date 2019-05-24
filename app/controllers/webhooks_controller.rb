# frozen_string_literal: true

class WebhooksController < ApplicationController
  skip_before_filter :verify_authenticity_token

  def github
    Rails.logger.info("received github payload: #{params[:payload]}")

    return render json: { success: true } if params[:payload].nil? # sometimes github sends blank requests

    payload = JSON.parse(params[:payload])

    repository = payload["repository"]
    repo = Repo.find_by(organization: repository["owner"]["name"],
                        name: repository["name"])

    if payload["ref"].split("/").last == repo.branch
      commit = payload["commits"].last
      repo.commits.create!(
        author_name: commit["author"]["name"],
        email: commit["author"]["email"],
        sha1: commit["id"],
        message: commit["message"]
      )
    end

    render json: { success: true }
  end

  def deploy_script
    if request.authorization.nil?
      return render json: { success: false }, status: :unauthorized
    end
    http_basic_auth = ::Base64.decode64(request.authorization.split(" ", 2).last || "")
    decoded_credentials = http_basic_auth.split(":")
    username = decoded_credentials[0]
    password = decoded_credentials[1]
    if (username != Figaro.env.DEPLOY_SCRIPT_USERNAME) || (password != Figaro.env.DEPLOY_SCRIPT_PASSWORD)
      return render json: { success: false }, status: :unauthorized
    end

    Rails.logger.info("received deploy script commits and status: #{params[:commits]} #{params[:status]}")

    commits = params[:commits]
    status = params[:status]

    updated_count = 0
    commits.each do |commit_id|
      commit = Commit.find_by_sha1(commit_id)
      if !commit.nil? && commit.deploy_status != status
        commit.update_deploy_status(status)
        updated_count += 1
      end
    end

    render json: { success: true, updated: updated_count }
  end
end
