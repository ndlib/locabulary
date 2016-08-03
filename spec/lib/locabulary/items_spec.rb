require 'spec_helper'
require 'locabulary/items'

RSpec.describe Locabulary::Items do
  context '#build' do
    it "finds a defined subclass" do
      expect(described_class.build(predicate_name: 'administrative_units')).to(
        be_a(Locabulary::Item::AdministrativeUnit)
      )
    end

    it "defaults to the Item::Base" do
      expect(described_class.build(predicate_name: 'chicken')).to(be_a(Locabulary::Item::Base))
    end
  end
  context '#builder_for' do
    it "finds a defined subclass" do
      expect(described_class.builder_for(predicate_name: 'administrative_units').call).to(
        be_a(Locabulary::Item::AdministrativeUnit)
      )
    end

    it "defaults to the Item::Base" do
      expect(described_class.builder_for(predicate_name: 'chicken').call).to(be_a(Locabulary::Item::Base))
    end
  end
end
