require 'spec_helper'
require 'locabulary/command/build_ordered_hierarchical_tree'
require 'spec_helper/facetable_struct'

module Locabulary
  module Command
    RSpec.describe BuildOrderedHierarchicalTree do
      context '.call' do
        subject { described_class.call(predicate_name: 'chicken', faceted_items: faceted_items, faceted_item_hierarchy_delimiter: '::') }
        context 'with a well formed tree' do
          let(:faceted_items) do
            [
              FacetableStruct.new('Hello', 'Hello', 2),
              FacetableStruct.new('Ardvark', 'Ardvark', 4),
              FacetableStruct.new('Hello::World', 'Hello::World', 8)
            ]
          end
          it 'returns a sorted Array of Locabulary::Item objects' do
            mapper = ->(item) { [item.predicate_name, item.term_label] }
            expect(subject.map(&mapper)).to eq([%w(chicken Ardvark), %w(chicken Hello)])
          end
        end

        context 'with a tree that has gaps between nodes' do
          let(:faceted_items) do
            [
              FacetableStruct.new('Hello', 'Hello', 2),
              FacetableStruct.new('Hello::World::NowFail', 'Hello::World::NowFail', 8)
            ]
          end
          it 'will raise Exceptions::MissingHierarchicalParentError' do
            expect { subject }.to raise_error(Locabulary::Exceptions::MissingHierarchicalParentError)
          end
        end
      end
    end
  end
end
