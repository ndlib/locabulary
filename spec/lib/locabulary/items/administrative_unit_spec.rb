require 'spec_helper'
require 'locabulary/items/administrative_unit'

RSpec.describe Locabulary::Items::AdministrativeUnit do
  subject { described_class.new }
  its(:attribute_names) { should include(:predicate_name) }
  its(:attribute_names) { should include(:term_label) }
  its(:attribute_names) { should include(:term_uri) }
  its(:attribute_names) { should include(:description) }
  its(:attribute_names) { should include(:grouping) }
  its(:attribute_names) { should include(:affiliation) }
  its(:attribute_names) { should include(:default_presentation_sequence) }
  its(:attribute_names) { should include(:activated_on) }
  its(:attribute_names) { should include(:deactivated_on) }

  context '.hierarchical_root' do
    it 'works if the hierarchy does not have skipped nodes' do
      item1 = Locabulary::Items::AdministrativeUnit.new(term_label: 'Universe::Non-Galactic')
      item2 = Locabulary::Items::AdministrativeUnit.new(term_label: 'Universe::Galaxy::Planet')
      item3 = Locabulary::Items::AdministrativeUnit.new(term_label: 'Universe')
      item4 = Locabulary::Items::AdministrativeUnit.new(term_label: 'Universe::Galaxy')
      item5 = Locabulary::Items::AdministrativeUnit.new(term_label: 'Universe::Galaxy::Ketchup')
      root = described_class.hierarchical_root([item1, item2, item3, item4, item5])

      expect(root).to eq(item3)
      expect(root.children.size).to eq(2)
      expect(root.children).to eq([item1, item4])
      expect(item4.children).to eq([item2, item5])
      expect(item1.children).to eq([])
    end

    xit 'fails if we have empty spaces between our nodes'
    xit 'fails if we have more than one root node'
  end
end
