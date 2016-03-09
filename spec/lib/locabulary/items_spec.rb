require 'spec_helper'
require 'locabulary/items'

RSpec.describe Locabulary::Items do
  context '#builder_for' do
    it "finds a defined subclass" do
      expect(described_class.builder_for(predicate_name: 'administrative_units').call).to(
        be_a(Locabulary::Items::AdministrativeUnit)
      )
    end

    it "defaults to the base Locabulary::Item" do
      expect(described_class.builder_for(predicate_name: 'chicken').call).to(be_a(Locabulary::Item))
    end
  end
end
