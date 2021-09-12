# frozen_string_literal: true

require "test_helper"

class UsersControllerTest < ActionController::TestCase
  include Devise::Test::ControllerHelpers

  def assert_redirect
    assert_redirected_to(controller: "public")
    assert_equal("Please log in to continue.", flash[:notice])
  end

  test "redirect from /onboarding if not logged in" do  
    get :onboarding
    assert_redirect
  end
  
  test "redirect from /onboarding/slack if not logged in" do  
    get :onboarding_slack
    assert_redirect
  end
end
