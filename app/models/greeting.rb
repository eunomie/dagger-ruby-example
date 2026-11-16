class Greeting < ApplicationRecord
  validates :name, presence: true

  def message = "Hello, #{name}!"
end
