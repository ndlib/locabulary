require 'spec_helper'
require 'date'
require 'locabulary/services/item_for_service'
require 'locabulary/items/base'

module Locabulary
  module Services
    RSpec.describe ItemForService do
      context '.call' do
        # uses data file '../../data/spec.json'
        let(:as_of_date) { Date.parse('2016-08-01') }
        let(:options) do
          { predicate_name: 'spec',
            search_term_key: one_key,
            search_term_value: one_value,
            as_of: Date.today }
        end

        context 'returns an active item for' do
          let(:one_key) { 'term_label' }
          let(:one_value) { 'Active Item' }

          it 'search key "term_label"' do
            item = described_class.call(options)
            expect(item).to be_a(Locabulary::Items::Base)
          end
        end
        context 'returns an active item for' do
          let(:one_key) { 'acronym' }
          let(:one_value) { 'abcde' }

          it 'search key "acronym"' do
            item = described_class.call(options)
            expect(item).to be_a(Locabulary::Items::Base)
            expect(item.term_label).to eq("Active Item with Acronym")
          end
        end
        context 'if item not found' do
          let(:one_key) { 'acronym' }
          let(:one_value) { 'fgh' }
          let(:subject) { described_class.call(options) }

          it 'returns error' do
            expect { subject }.to raise_error(Locabulary::Exceptions::ItemNotFoundError)
          end
        end
        it 'returns a found deactived item if no active item is found for the given predicate_name and label' do
          item = described_class.call(predicate_name: 'spec',
                                      search_term_key: 'term_label',
                                      search_term_value: 'Deactive Item',
                                      as_of: as_of_date)
          expect(item).to be_a(Locabulary::Items::Base)
        end
      end
    end
  end
end
