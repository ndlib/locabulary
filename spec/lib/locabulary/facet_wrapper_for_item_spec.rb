require 'spec_helper'
require 'spec_helper/facetable_struct'
require 'locabulary/facet_wrapper_for_item'
require 'locabulary/items/base'

module Locabulary
  RSpec.describe FacetWrapperForItem do
    let(:item) { Items::Base.new(predicate_name: 'hello', term_label: 'world') }
    let(:faceted_node) { FacetableStruct.new('my_qvalue', 'my_value', 123) }
    subject { described_class.new(faceted_node: faceted_node, locabulary_item: item) }

    it { is_expected.to respond_to(:qvalue) }
    it { is_expected.to respond_to(:value) }
    it { is_expected.to respond_to(:hits) }
    it { is_expected.to respond_to(:term_label) }

    context 'Comparable' do
      let(:item1) { Items::Base.new(predicate_name: 'hello', term_label: 'world') }
      let(:item2) { Items::Base.new(predicate_name: 'hello', term_label: 'different world') }
      let(:faceted_node1) { FacetableStruct.new('my_qvalue', 'my_value', 123) }
      let(:faceted_node2) { FacetableStruct.new('my_diff_qvalue', 'my_diff_value', 2) }
      let(:wrapper1) { described_class.new(locabulary_item: item1, faceted_node: faceted_node1) }
      let(:wrapper2) { described_class.new(locabulary_item: item2, faceted_node: faceted_node2) }

      it 'should sort the same as the underlying item' do
        sort_value_for_wrappers = wrapper1.<=>(wrapper2)
        sort_value_for_items = item1.<=>(item2)
        expect(sort_value_for_wrappers).to eq(sort_value_for_items)
      end

      context 'sort on an array of wrappers' do
        it 'should return the wrappers in their underlying sort order' do
          expect([wrapper1, wrapper2].sort).to eq([wrapper2, wrapper1])
        end
      end
    end
  end
end
