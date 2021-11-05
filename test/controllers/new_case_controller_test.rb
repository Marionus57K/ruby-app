require "test_helper"

class NewCaseControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get new_case_index_url
    assert_response :success
  end
end
