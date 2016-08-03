require 'spec_helper'
require 'locabulary/item/administrative_unit'

RSpec.describe Locabulary::Item::AdministrativeUnit do
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

  subject { Locabulary::Item::AdministrativeUnit.new(term_label: 'Universe::Galaxy::Planet') }
  context '#selectable?' do
    it 'is true if there are no children' do
      allow(subject).to receive(:children).and_return([])
      expect(subject).to be_selectable
    end

    it 'is false if there are children' do
      allow(subject).to receive(:children).and_return([1, 2, 3])
      expect(subject).to_not be_selectable
    end
  end

  context '#add_child' do
    it 'updates the children' do
      expect { subject.add_child('tuna', 'sandwich') }.to change { subject.children.count }.by(2)
    end
  end

  context '#selectable_label' do
    it 'is the last slug' do
      expect(subject.selectable_label).to eq('Planet')
    end
    it 'is the second to last and last slug if we have a Non-Departmental last slug' do
      subject = Locabulary::Item::AdministrativeUnit.new(term_label: "Universe::Galaxy::#{described_class::NON_DEPARTMENTAL_SLUG}")
      expect(subject.selectable_label).to eq(
        "Galaxy#{described_class::HUMAN_FRIENDLY_HIERARCHY_SEPARATOR}#{described_class::NON_DEPARTMENTAL_SLUG}"
      )
    end
  end

  context 'slug methods' do
    subject { Locabulary::Item::AdministrativeUnit.new(term_label: 'Universe::Galaxy::Planet') }

    its(:root_slug) { should eq('Universe') }
    its(:parent_slugs) { should eq(%w(Universe Galaxy)) }
    its(:slugs) { should eq(%w(Universe Galaxy Planet)) }
    its(:parent_term_label) { should eq('Universe::Galaxy') }
  end
end
