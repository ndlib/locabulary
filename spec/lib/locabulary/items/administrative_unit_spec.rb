require 'spec_helper'
require 'locabulary/items/administrative_unit'

RSpec.describe Locabulary::Items::AdministrativeUnit do
  subject { described_class.new }
  its(:attribute_names) { should include(:predicate_name) }
  its(:attribute_names) { should include(:term_label) }
  its(:attribute_names) { should include(:term_uri) }
  its(:attribute_names) { should include(:description) }
  its(:attribute_names) { should include(:grouping) }
  its(:attribute_names) { should include(:classification) }
  its(:attribute_names) { should include(:affiliation) }
  its(:attribute_names) { should include(:default_presentation_sequence) }
  its(:attribute_names) { should include(:activated_on) }
  its(:attribute_names) { should include(:deactivated_on) }

  context '.hierarchy_delimiter' do
    subject { described_class.hierarchy_delimiter }
    it { is_expected.to be_a(String) }
  end

  subject { described_class.new(term_label: 'Universe::Galaxy::Planet') }

  context '#selectable_label' do
    it 'is the last slug' do
      expect(subject.selectable_label).to eq('Planet')
    end
    it 'is the second to last and last slug if we have a Non-Departmental last slug' do
      subject = described_class.new(term_label: "Universe::Galaxy::#{described_class::NON_DEPARTMENTAL_SLUG}")
      expect(subject.selectable_label).to eq(
        "Galaxy#{described_class::HUMAN_FRIENDLY_HIERARCHY_DELIMITER}#{described_class::NON_DEPARTMENTAL_SLUG}"
      )
    end
  end
end
