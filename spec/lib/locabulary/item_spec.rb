require 'spec_helper'
require 'locabulary/item'

RSpec.describe Locabulary::Item do
  context 'Comparable' do
    it 'sorts with nil and integers for presentation sequence' do
      item_1 = Locabulary::Item.new(default_presentation_sequence: nil, term_label: 'Hello')
      item_2 = Locabulary::Item.new(default_presentation_sequence: 2, term_label: 'World')
      item_3 = Locabulary::Item.new(default_presentation_sequence: nil, term_label: 'Help')
      item_4 = Locabulary::Item.new(default_presentation_sequence: 1, term_label: 'Bob')
      item_5 = Locabulary::Item.new(default_presentation_sequence: 2, term_label: 'Apple')

      expect([item_1, item_2, item_3, item_4, item_5].sort).to eq([item_4, item_5, item_2, item_1, item_3])
    end
  end
end
