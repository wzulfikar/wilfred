# frozen_string_literal: true

require "test_helper"
require "json"

class WebhooksControllerTest < ActionController::TestCase
  test "should create commit on `push` event from github" do
    repo = repos(:repo)
    post :github, payload: File.read("test/files/example_push_payload.json").to_s
    assert_equal(1, repo.commits.count)
    assert_response :success
  end
end
