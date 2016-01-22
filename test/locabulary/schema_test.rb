require 'minitest/autorun'
require 'json'
require 'locabulary/schema'
require 'active_support/core_ext/hash/keys'

module Locabulary
  class SchemaTest < MiniTest::Test

    Dir.glob(File.join(File.dirname(__FILE__), '../../data/*.json')).each do |filename|
      define_method "test_schema_against_data_#{File.basename(filename, ".json")}" do
        json = JSON.parse(File.read(filename)).deep_symbolize_keys
        schema = Locabulary::Schema.new
        assert_equal({}, schema.call(json).messages)
      end
    end
  end
end
