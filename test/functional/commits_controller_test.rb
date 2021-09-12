# frozen_string_literal: true

require "test_helper"

class CommitsControllerTest < ActionController::TestCase
  include Devise::Test::ControllerHelpers

  test "redirect from /commits if not logged in" do  
    get :index
    assert_redirected_to(controller: "public")
    assert_equal("Please log in to continue.", flash[:notice])
  end
end
