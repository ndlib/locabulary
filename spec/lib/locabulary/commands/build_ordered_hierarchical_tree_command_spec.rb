require 'spec_helper'
require 'locabulary/commands/build_ordered_hierarchical_tree_command'
require 'spec_helper/facetable_struct'

module Locabulary
  module Commands
    RSpec.describe BuildOrderedHierarchicalTreeCommand do
      context '.call' do
        subject do
          described_class.call(predicate_name: 'chicken', faceted_items: faceted_items, faceted_item_hierarchy_delimiter: '::')
        end
        context 'with a missing predicate_name data store' do
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

        context 'with a predicate_name that has a data store' do
          subject do
            described_class.call(predicate_name: 'spec', faceted_items: faceted_items, faceted_item_hierarchy_delimiter: '::')
          end
          context 'with a mix of missing and existing items' do
            let(:faceted_items) do
              [
                FacetableStruct.new('Deactive Item', 'Deactive Item', 3),
                FacetableStruct.new('Active Item', 'Active Item', 2),
                FacetableStruct.new('Alternate Item', 'Alternate Item', 8),
                FacetableStruct.new('Aardvark of Activity', 'Aardvark of Activity', 16)
              ]
            end

            it 'returns a sorted Array of Locabulary::Item objects' do
              mapper = ->(item) { [item.predicate_name, item.term_label] }
              expect(subject.map(&mapper)).to eq(
                [["spec", "Deactive Item"], ["spec", "Alternate Item"], ["spec", "Active Item"], ["spec", "Aardvark of Activity"]]
              )
            end
          end
        end
      end
    end
  end
end
