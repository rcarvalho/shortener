ENV['APP_ENV'] = 'test'

require 'rspec'
require 'rack/test'

# Within `spec/spec_helper.rb`
RSpec.configure do |config|
  config.mock_with :mocha
end