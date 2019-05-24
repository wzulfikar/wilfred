# frozen_string_literal: true

class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def github
    omniauth_params = request.env["omniauth.auth"]

    username = omniauth_params[:info][:nickname]
    user = User.find_by_username(username)

    if user.nil?
      octokit = Octokit::Client.new(access_token: omniauth_params["credentials"]["token"])

      if Repo.count == 0 || octokit.organizations.map(&:login).include?(Repo.first.organization)
        user = User.create(name: omniauth_params["info"]["name"], username: username, email: omniauth_params["info"]["email"])
      else
        return render json: { success: false, error: "Sorry, but it doesn't look like you're a member of #{Repo.first.organization}." }
      end
    end

    user.provider = "github"
    user.uid = omniauth_params["uid"]
    user.github_access_token = omniauth_params["credentials"]["token"]
    user.save!

    sign_in user
    redirect_to root_url
  end

  def slack
    omniauth_params = request.env["omniauth.auth"]
    current_user.update_attribute(:slack_username, omniauth_params["info"]["user_id"])
    current_user.update_attribute(:slack_access_token, omniauth_params["credentials"]["token"])
    redirect_to root_url
  end
end
