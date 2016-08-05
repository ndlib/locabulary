require 'spec_helper'
require 'spec_helper/facetable_struct'
require 'locabulary/facet_wrapper_for_item'
require 'locabulary/items/base'

module Locabulary
  RSpec.describe FacetWrapperForItem do
    let(:faceted_node) { FacetableStruct.new('my_qvalue', 'my_value', 123) }
    context '.build_for_faceted_node_and_locabulary_item' do
      let(:item) { Items::Base.new(predicate_name: 'hello', term_label: 'world') }
      subject { described_class.build_for_faceted_node_and_locabulary_item(faceted_node: faceted_node, locabulary_item: item) }

      it 'builds an underlying Locabulary::Items::Base object' do
        expect(subject.term_label).to eq('world')
      end
      it { is_expected.to be_a(described_class) }
      it { is_expected.to delegate_method(:qvalue).to(:__faceted_node__) }
      it { is_expected.to delegate_method(:value).to(:__faceted_node__) }
      it { is_expected.to delegate_method(:hits).to(:__faceted_node__) }
    end

    context '.build_for_faceted_node' do
      subject do
        described_class.build_for_faceted_node(faceted_node: faceted_node, predicate_name: 'administrative_units', term_label: 'world')
      end
      it 'builds an underlying Locabulary::Items::Base object' do
        expect(subject.term_label).to eq('world')
      end
      it { is_expected.to be_a(described_class) }
      it { is_expected.to delegate_method(:qvalue).to(:__faceted_node__) }
      it { is_expected.to delegate_method(:value).to(:__faceted_node__) }
      it { is_expected.to delegate_method(:hits).to(:__faceted_node__) }
    end

    context 'Comparable' do
      let(:item1) { Items::Base.new(predicate_name: 'hello', term_label: 'world') }
      let(:item2) { Items::Base.new(predicate_name: 'hello', term_label: 'different world') }
      let(:faceted_node1) { FacetableStruct.new('my_qvalue', 'my_value', 123) }
      let(:faceted_node2) { FacetableStruct.new('my_diff_qvalue', 'my_diff_value', 2) }
      let(:wrapper1) { described_class.build_for_faceted_node_and_locabulary_item(locabulary_item: item1, faceted_node: faceted_node1) }
      let(:wrapper2) { described_class.build_for_faceted_node_and_locabulary_item(locabulary_item: item2, faceted_node: faceted_node2) }

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
