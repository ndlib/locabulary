require 'spec_helper'
require 'locabulary/items/base'

RSpec.describe Locabulary::Items::Base do
  context 'Comparable' do
    it 'sorts with nil and integers for presentation sequence' do
      item1 = described_class.new(default_presentation_sequence: nil, term_label: 'Hello')
      item2 = described_class.new(default_presentation_sequence: 2, term_label: 'World')
      item3 = described_class.new(default_presentation_sequence: nil, term_label: 'Help')
      item4 = described_class.new(predicate_name: 'b', default_presentation_sequence: 1, term_label: 'Bob')
      item5 = described_class.new(predicate_name: 'a', default_presentation_sequence: 2, term_label: 'Apple')

      expect([item1, item2, item3, item4, item5].sort).to eq([item2, item1, item3, item5, item4])
    end
  end

  it 'will have a #to_h with keys that are the ATTRIBUTE_NAMES' do
    item = described_class.new(default_presentation_sequence: 2, term_label: 'Apple')
    expect(item.to_h.keys).to eq(%w(term_label default_presentation_sequence))
  end

  subject { described_class.new(term_label: 'Universe::Galaxy::Planet') }
  its(:as_json) { should be_a(Hash) }

  context '#default_presentation_sequence=' do
    [
      ['', nil], ['1', 1], ['a', 0], [nil, nil]
    ].each do |given, expected|
      it "will coerce #{given.inspect} to #{expected.inspect}" do
        expect(described_class.new(default_presentation_sequence: given).default_presentation_sequence).to eq(expected)
      end
    end
  end

  context '#id' do
    it 'is an alias for #to_persistence_format_for_fedora' do
      expect(subject.id).to eq(subject.to_persistence_format_for_fedora)
    end
  end

  context '#to_persistence_format_for_fedora' do
    it 'is the term_label if no term_uri is given' do
      subject = described_class.new(term_label: 'Hello')
      subject.to_persistence_format_for_fedora == 'Hello'
    end
    it 'is the term_uri if one is given' do
      subject = described_class.new(term_label: 'Hello', term_uri: 'http://goodbye.com')
      subject.to_persistence_format_for_fedora == 'http://goodbye.com'
    end
  end

  context '.hierarchy_delimiter' do
    subject { described_class.hierarchy_delimiter }
    it { is_expected.to be_a(String) }
  end

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
  end

  context '#hierarchy_facet_label' do
    it 'is the last slug' do
      expect(subject.hierarchy_facet_label).to eq('Planet')
    end
  end

  context 'slug methods' do
    subject { described_class.new(term_label: 'Universe::Galaxy::Planet') }

    its(:root_slug) { should eq('Universe') }
    its(:parent_slugs) { should eq(%w(Universe Galaxy)) }
    its(:slugs) { should eq(%w(Universe Galaxy Planet)) }
    its(:parent_term_label) { should eq('Universe::Galaxy') }
  end
end
