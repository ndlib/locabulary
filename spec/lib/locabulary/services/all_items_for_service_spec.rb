require 'spec_helper'
require 'locabulary/services/all_items_for_service'

module Locabulary
  module Services
    RSpec.describe AllItemsForService do
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

        context 'with never active items in data' do
          let(:predicate_name) { 'spec' }
          subject { described_class.call(predicate_name: predicate_name) }
          it 'will exclude never activated items' do
            expect(subject.count).to eq(5)
          end
        end
      end
    end
  end
end
