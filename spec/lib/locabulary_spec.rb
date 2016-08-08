require 'spec_helper'
require 'locabulary'
require 'locabulary/items/base'

RSpec.describe Locabulary do
  context '.build_ordered_hierarchical_tree' do
    it 'will delegate to Services' do
      parameters = { predicate_name: 'predicate_name', faceted_items: [1, 2, 3], faceted_item_hierarchy_delimiter: ':' }
      expect(Locabulary::Services).to receive(:call).with(:build_ordered_hierarchical_tree, parameters)
      described_class.build_ordered_hierarchical_tree(parameters)
    end
  end

  context '.active_items_for' do
    it 'will delegate to Services' do
      parameters = { predicate_name: 'predicate_name' }
      expect(Locabulary::Services).to receive(:call).with(:active_items_for, parameters)
      described_class.active_items_for(parameters)
    end
  end

  context '.active_hierarchical_roots' do
    it 'will delegate to Services' do
      parameters = { predicate_name: 'predicate_name' }
      expect(Locabulary::Services).to receive(:call).with(:active_hierarchical_roots, parameters)
      described_class.active_hierarchical_roots(parameters)
    end
  end

  context '.item_for' do
    # uses data file '../../data/spec.json'
    let(:as_of_date) { Date.parse('2016-08-01') }
    it 'returns an active item for the given predicate_name and label' do
      item = described_class.item_for(predicate_name: 'spec', term_label: 'Active Item', as_of: Date.today)
      expect(item).to be_a(Locabulary::Items::Base)
    end
    it 'returns a found deactived item if no active item is found for the given predicate_name and label' do
      item = described_class.item_for(predicate_name: 'spec', term_label: 'Deactive Item', as_of: as_of_date)
      expect(item).to be_a(Locabulary::Items::Base)
    end
    it 'raises an exception if no item is found' do
      expect do
        described_class.item_for(predicate_name: 'spec', term_label: 'Very Much Missing')
      end.to raise_error(Locabulary::Exceptions::ItemNotFoundError)
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
      label = Locabulary.active_label_for_uri(predicate_name: 'copyright', term_uri: 'http://creativecommons.org/licenses/by/3.0/us/')
      expect(label).to eq('Attribution 3.0 United States')
    end
    it 'will use the term_uri if a uri cannot be found' do
      label = Locabulary.active_label_for_uri(predicate_name: 'copyright', term_uri: 'Chompy')
      expect(label).to eq('Chompy')
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
