require 'spec_helper'
require 'locabulary/services/item_for_command'
require 'spec_helper/facetable_struct'

module Locabulary
  module Services
    RSpec.describe ItemForCommand do
      context '.call' do
        # uses data file '../../data/spec.json'
        let(:as_of_date) { Date.parse('2016-08-01') }
        it 'returns an active item for the given predicate_name and label' do
          item = described_class.call(predicate_name: 'spec', term_label: 'Active Item', as_of: Date.today)
          expect(item).to be_a(Locabulary::Items::Base)
        end
        it 'returns a found deactived item if no active item is found for the given predicate_name and label' do
          item = described_class.call(predicate_name: 'spec', term_label: 'Deactive Item', as_of: as_of_date)
          expect(item).to be_a(Locabulary::Items::Base)
        end
        it 'raises an exception if no item is found' do
          expect do
            described_class.call(predicate_name: 'spec', term_label: 'Very Much Missing')
          end.to raise_error(Locabulary::Exceptions::ItemNotFoundError)
        end
      end
    end
  end
end
