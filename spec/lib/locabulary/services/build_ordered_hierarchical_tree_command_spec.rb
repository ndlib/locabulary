require 'spec_helper'
require 'locabulary/services/build_ordered_hierarchical_tree_command'
require 'spec_helper/facetable_struct'

module Locabulary
  module Services
    RSpec.describe BuildOrderedHierarchicalTreeCommand do
      context '.call' do
        let(:mapper_for_specs) { ->(item) { [item.predicate_name, item.term_label] } }
        subject do
          described_class.call(predicate_name: 'chicken', faceted_items: faceted_items, faceted_item_hierarchy_delimiter: '::')
        end
        context 'with a missing predicate_name data store' do
          context 'with a well formed tree' do
            let(:faceted_items) do
              [
                FacetableStruct.new('Hello', 2),
                FacetableStruct.new('Ardvark', 4),
                FacetableStruct.new('Hello::World', 8)
              ]
            end
            it 'returns a sorted Array of Locabulary::Item objects' do
              expect(subject.map(&mapper_for_specs)).to eq([%w(chicken Ardvark), %w(chicken Hello)])
            end
          end

          context 'with a tree that has gaps between nodes' do
            let(:faceted_items) do
              [
                FacetableStruct.new('Hello', 2),
                FacetableStruct.new('Hello::World::NowFail', 8)
              ]
            end
            it 'will raise Exceptions::MissingHierarchicalParentError' do
              expect { subject }.to raise_error(Locabulary::Exceptions::MissingHierarchicalParentError)
            end
          end
        end

        context 'with a predicate_name that has a data store' do
          context 'with a mix of missing and existing items' do
            subject do
              described_class.call(predicate_name: 'spec', faceted_items: faceted_items, faceted_item_hierarchy_delimiter: '::')
            end
            let(:faceted_items) do
              [
                FacetableStruct.new('Deactive Item', 3),
                FacetableStruct.new('Active Item', 2),
                FacetableStruct.new('Alternate Item', 8),
                FacetableStruct.new('Aardvark of Activity', 16)
              ]
            end

            it 'returns a sorted Array of Locabulary::Item objects' do
              expect(subject.map(&mapper_for_specs)).to eq(
                [["spec", "Deactive Item"], ["spec", "Alternate Item"], ["spec", "Active Item"], ["spec", "Aardvark of Activity"]]
              )
            end
          end

          context 'with administrative_units as returned from blacklight' do
            # NOTE: The delimiter is a single colon as expected from blacklight.
            # This is not the same as what is stored in Locabulary
            let(:faceted_item_hierarchy_delimiter) { ":" }
            subject do
              described_class.call(
                predicate_name: 'administrative_units',
                faceted_items: faceted_items,
                faceted_item_hierarchy_delimiter: faceted_item_hierarchy_delimiter
              )
            end
            let(:faceted_items) do
              [
                FacetableStruct.new('University of Notre Dame', 1),
                FacetableStruct.new("University of Notre Dame#{faceted_item_hierarchy_delimiter}College of Arts and Letters", 3),
                FacetableStruct.new("University of Notre Dame#{faceted_item_hierarchy_delimiter}School of Architecture", 2)
              ]
            end

            it 'returns a sorted Array of Locabulary::Item objects' do
              roots = subject
              expect(roots.map(&mapper_for_specs)).to eq([["administrative_units", "University of Notre Dame"]])

              expect(roots.first.children.map(&mapper_for_specs)).to eq(
                [
                  ["administrative_units", "University of Notre Dame::School of Architecture"],
                  ["administrative_units", "University of Notre Dame::College of Arts and Letters"]
                ]
              )
            end
          end
        end
      end
    end
  end
end
