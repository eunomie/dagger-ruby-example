class GreetingsController < ApplicationController
  def index
    @greetings = Greeting.order(:name)
  end
end
