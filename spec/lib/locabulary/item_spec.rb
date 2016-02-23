require 'spec_helper'
require 'locabulary/item'

RSpec.describe Locabulary::Item do
  context 'Comparable' do
    it 'sorts with nil and integers for presentation sequence' do
      item_1 = described_class.new(default_presentation_sequence: nil, term_label: 'Hello')
      item_2 = described_class.new(default_presentation_sequence: 2, term_label: 'World')
      item_3 = described_class.new(default_presentation_sequence: nil, term_label: 'Help')
      item_4 = described_class.new(default_presentation_sequence: 1, term_label: 'Bob')
      item_5 = described_class.new(default_presentation_sequence: 2, term_label: 'Apple')

      expect([item_1, item_2, item_3, item_4, item_5].sort).to eq([item_4, item_5, item_2, item_1, item_3])
    end
  end

  it 'will have a #to_h with keys that are the ATTRIBUTE_NAMES' do
    item = described_class.new(default_presentation_sequence: 2, term_label: 'Apple')
    expect(item.to_h.keys).to eq(%w(term_label default_presentation_sequence))
  end

  its(:as_json) { should be_a(Hash) }
end
