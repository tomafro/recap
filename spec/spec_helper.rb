require 'recap'
require 'faker'
require 'mustache'

Recap::Support::Namespace.default_config = nil

Mustache.template_path = File.expand_path('../support/templates', __FILE__)
Dir[File.expand_path('../support/**/*.rb', __FILE__)].each {|f| require f}

class Mustache
  def to_s
    render
  end
end

RSpec.configure do |config|
  config.mock_with :mocha
end
