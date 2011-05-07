require 'test_helper'

class BenchControllerTest < ActionController::TestCase
  test "should get erubis" do
    get :erubis
    assert_response :success
  end

  test "should get hammer_builder" do
    get :hammer_builder
    assert_response :success
  end

end
