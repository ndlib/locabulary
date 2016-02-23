GEM_ROOT = File.expand_path('../../', __FILE__)
$LOAD_PATH.unshift File.join(GEM_ROOT, 'lib')

require 'rspec'
require 'rspec/its'
require 'coverage_helper'

RSpec.configure do |config|
  # rspec-mocks config goes here. You can use an alternate test double
  # library (such as bogus or mocha) by changing the `mock_with` option here.
  config.mock_with :rspec do |mocks|
    # Prevents you from mocking or stubbing a method that does not exist on
    # a real object. This is generally recommended, and will default to
    # `true` in RSpec 4.
    mocks.verify_partial_doubles = true
  end

  # config.disable_monkey_patching!
  # config.warnings = true
  config.order = :random
  Kernel.srand config.seed
end
