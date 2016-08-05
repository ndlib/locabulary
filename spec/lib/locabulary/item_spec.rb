require 'spec_helper'
require 'locabulary/item'

RSpec.describe Locabulary::Item do
  context '#build' do
    it "finds a defined subclass" do
      expect(described_class.build(predicate_name: 'administrative_units')).to(
        be_a(Locabulary::Items::AdministrativeUnit)
      )
    end

    it "defaults to the Items::Base" do
      expect(described_class.build(predicate_name: 'chicken')).to(be_a(Locabulary::Items::Base))
    end
  end
  context '#builder_for' do
    it "finds a defined subclass" do
      expect(described_class.builder_for(predicate_name: 'administrative_units').call).to(
        be_a(Locabulary::Items::AdministrativeUnit)
      )
    end

    it "defaults to the Items::Base" do
      expect(described_class.builder_for(predicate_name: 'chicken').call).to(be_a(Locabulary::Items::Base))
    end
  end
end
