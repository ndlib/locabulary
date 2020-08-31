# So, we don't actually use the schema, except when testing do we have
# valid data (e.g. is the JSON properly formed).  And due to 2.3.x
# oddities in Dry::Schema, I can't get both 2.3.8 and 2.4.x+ to run
# using the same logic path.
#
# Again, since we are ONLY testing is the data well formed, we don't
# need ALL ruby versions to test this.
if RUBY_VERSION !~ /^2\.[0123]/
  require 'spec_helper'
  require 'json'
  require 'active_support/core_ext/hash/keys'
  require 'dry/schema'

  module Locabulary
    # Responsible for providing a defined and clear schema for each of the locabulary items.
    Schema = Dry::Schema.JSON do
      required(:predicate_name).filled(format?: /\A[a-z_]+\Z/)
      required(:values).value(:array).each do
        schema do
          required(:term_label).filled(:str?)
          optional(:description).maybe(:str?)
          optional(:grouping).maybe(:str?)
          optional(:affiliation).maybe(:str?)
          optional(:default_presentation_sequence).maybe(:int?)
          required(:activated_on).filled(format?: /\A\d{4}-\d{2}-\d{2}\Z/)
          optional(:deactivated_on).maybe(format?: /\A\d{4}-\d{2}-\d{2}\Z/)
        end
      end
    end
  end

  RSpec.describe Locabulary::Schema do
    Dir.glob(File.join(File.dirname(__FILE__), '../../../data/*.json')).each do |filename|
      context "for #{File.basename(filename, '.json')}" do
        it "has a valid schema" do
          json = JSON.parse(File.read(filename)).deep_symbolize_keys
          expect(Locabulary::Schema.call(json).errors).to be_empty
        end
      end
    end
  end
end
