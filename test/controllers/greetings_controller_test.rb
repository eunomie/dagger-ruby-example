require "test_helper"

class GreetingsControllerTest < ActionDispatch::IntegrationTest
  test "lists greetings by name" do
    Greeting.create!(name: "Grace")
    Greeting.create!(name: "Ada")

    get root_path

    assert_response :success
    assert_equal ["Hello, Ada!", "Hello, Grace!"], css_select("li").map(&:text)
  end
end
