require 'spec_helper'
require 'json'
require 'locabulary/schema'
require 'active_support/core_ext/hash/keys'

RSpec.describe Locabulary::Schema do
  Dir.glob(File.join(File.dirname(__FILE__), '../../../data/*.json')).each do |filename|
    context "for #{File.basename(filename, '.json')}" do
      it "has a valid schema" do
        json = JSON.parse(File.read(filename)).deep_symbolize_keys
        schema = Locabulary::Schema.new
        expect(schema.call(json).messages).to eq({})
      end
    end
  end
end
