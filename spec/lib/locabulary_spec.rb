require 'spec_helper'
require 'locabulary'
require 'locabulary/items/base'

module Locabulary
  RSpec.describe 'interface' do
    let(:described_class) { Locabulary }
    context '.build_ordered_hierarchical_tree' do
      it 'will delegate to Services' do
        parameters = { predicate_name: 'predicate_name', faceted_items: [1, 2, 3], faceted_item_hierarchy_delimiter: ':' }
        expect(Services).to receive(:call).with(:build_ordered_hierarchical_tree, parameters)
        described_class.build_ordered_hierarchical_tree(parameters)
      end
    end

    context '.active_items_for' do
      it 'will delegate to Services' do
        parameters = { predicate_name: 'predicate_name' }
        expect(Services).to receive(:call).with(:active_items_for, parameters)
        described_class.active_items_for(parameters)
      end
    end

    context '.all_items_for' do
      it 'will delegate to Services' do
        parameters = { predicate_name: 'predicate_name' }
        expect(Services).to receive(:call).with(:all_items_for, parameters)
        described_class.all_items_for(parameters)
      end
    end

    context '.active_hierarchical_roots' do
      it 'will delegate to Services' do
        parameters = { predicate_name: 'predicate_name' }
        expect(Services).to receive(:call).with(:active_hierarchical_roots, parameters)
        described_class.active_hierarchical_roots(parameters)
      end
    end

    context '.item_for' do
      it 'will delegate to Services' do
        options = { predicate_name: 'predicate_name' }
        expect(Services).to receive(:call).with(:item_for, options)
        described_class.item_for(options)
      end
    end

    context '.active_labels_for' do
      it 'will parse the given data' do
        result = Locabulary.active_labels_for(predicate_name: 'copyright')
        expect(result.first).to eq('All rights reserved')
      end
    end

    context '.active_label_for_uri' do
      it 'will use the label for the given term_uri' do
        label = Locabulary.active_label_for_uri(predicate_name: 'spec', term_uri: 'item:active')
        expect(label).to eq('Active Item')
      end
      it 'will use term_uri if the term is no longer active' do
        label = Locabulary.active_label_for_uri(predicate_name: 'spec', term_uri: 'item:deactive')
        expect(label).to eq('item:deactive')
      end
      it 'will use term_uri if nothing exists' do
        label = Locabulary.active_label_for_uri(predicate_name: 'spec', term_uri: 'item:__not_found__:because')
        expect(label).to eq('item:__not_found__:because')
      end
    end

    context 'verification that administrative units are unique' do
      it 'has unique adminstrative unit term labels' do
        content = JSON.parse(File.read(File.join(File.dirname(__FILE__), '../../data/administrative_units.json')))
        administrative_unit_ids = content.fetch('values').map { |item| item['term_label'] }
        expect(administrative_unit_ids.uniq).to eq(administrative_unit_ids)
      end
    end
  end
end
