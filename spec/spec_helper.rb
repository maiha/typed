$:.unshift File.expand_path('../../lib', __FILE__)

require 'rspec'
require 'typed'


RSpec.configure do |config|
  # == Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
  config.mock_with :rspec

  config.filter_run :focus => true
  config.run_all_when_everything_filtered = true
end


def tmp_path(file)
  Pathname(File.dirname(__FILE__)) + "../tmp" + file
end
