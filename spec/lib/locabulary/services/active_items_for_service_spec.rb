require 'spec_helper'
require 'locabulary/services/active_items_for_service'

module Locabulary
  module Services
    RSpec.describe ActiveItemsForService do
      before { described_class.reset_cache! }
      after { described_class.reset_cache! }
      context '.call' do
        let(:predicate_name) { 'copyright' }
        subject { described_class.call(predicate_name: predicate_name) }
        it 'will parse the given data' do
          expect(subject.first.term_label).to eq('All rights reserved')
        end
        it 'will build a cached_data' do
          expect { subject }.to change { described_class.send(:cache).keys }.from([]).to([predicate_name])
        end
      end

      context 'with as_of date' do
        let(:predicate_name) { 'spec' }
        let(:as_of_date) { Date.parse('2018-12-1') }
        subject { described_class.call(predicate_name: predicate_name, as_of: as_of_date) }
        it 'will exclude inactive items' do
          expect(subject.count).to eq(3)
        end
      end
    end
  end
end
