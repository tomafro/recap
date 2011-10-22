require 'recap'

Recap::Namespace.default_config = nil

RSpec.configure do |config|
  config.mock_with :mocha
end