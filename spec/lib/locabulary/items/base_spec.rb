require 'spec_helper'
require 'locabulary/items/base'

RSpec.describe Locabulary::Items::Base do
  context 'Comparable' do
    it 'sorts with nil and integers for presentation sequence' do
      item_1 = described_class.new(default_presentation_sequence: nil, term_label: 'Hello')
      item_2 = described_class.new(default_presentation_sequence: 2, term_label: 'World')
      item_3 = described_class.new(default_presentation_sequence: nil, term_label: 'Help')
      item_4 = described_class.new(predicate_name: 'b', default_presentation_sequence: 1, term_label: 'Bob')
      item_5 = described_class.new(predicate_name: 'a', default_presentation_sequence: 2, term_label: 'Apple')

      expect([item_1, item_2, item_3, item_4, item_5].sort).to eq([item_2, item_1, item_3, item_5, item_4])
    end
  end

  it 'will have a #to_h with keys that are the ATTRIBUTE_NAMES' do
    item = described_class.new(default_presentation_sequence: 2, term_label: 'Apple')
    expect(item.to_h.keys).to eq(%w(term_label default_presentation_sequence))
  end

  its(:as_json) { should be_a(Hash) }

  context '#id' do
    it 'is an alias for #to_persistence_format_for_fedora' do
      subject = described_class.new(term_label: 'Hello')
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
end
