require 'test_helper'

class AuthControllerTest < ActionDispatch::IntegrationTest
  test "should get authorize" do
    get auth_authorize_url
    assert_response :success
  end

end
