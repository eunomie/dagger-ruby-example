require "test_helper"

class GreetingTest < ActiveSupport::TestCase
  test "greets a saved name" do
    greeting = Greeting.create!(name: "Ada")
    assert_equal "Hello, Ada!", Greeting.find(greeting.id).message
  end

  test "requires a name" do
    assert_not Greeting.new(name: "").valid?
  end
end
