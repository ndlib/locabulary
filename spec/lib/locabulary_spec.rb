require 'spec_helper'
require 'locabulary'

RSpec.describe Locabulary do
  before { Locabulary.reset_active_cache! }

  context '.build_ordered_hierarchical_tree' do
    it 'will delegate to Commands::BuildOrderedHierarchicalTreeCommand' do
      parameters = { predicate_name: 'predicate_name', faceted_items: [1, 2, 3], faceted_item_hierarchy_delimiter: ':' }
      expect(Locabulary::Commands::BuildOrderedHierarchicalTreeCommand).to receive(:call).with(parameters)
      described_class.build_ordered_hierarchical_tree(parameters)
    end
  end

  context '.active_items_for' do
    it 'will delegate to Commands::ActiveItemsForCommand' do
      parameters = { predicate_name: 'predicate_name' }
      expect(Locabulary::Commands::ActiveItemsForCommand).to receive(:call).with(parameters)
      described_class.active_items_for(parameters)
    end
  end

  context '.active_hierarchical_roots' do
    it 'works for administrative_units' do
      results = Locabulary.active_hierarchical_roots(predicate_name: 'administrative_units')
      expect(results).to be_a(Array)
      expect(results.size).to be > 1
      results.each do |result|
        expect(result).to be_a(Locabulary::Item::AdministrativeUnit)
      end
    end

    it 'builds a hierarchical tree with well-formed data' do
      # Pardon for the antics; This method tests the guts of the logic for .active_hierarchical_roots. It is a bit more complicated as it
      # requires mapping hash data to items then querying the children of those built items.
      item1 = { term_label: 'Universe::Non-Galactic' }
      item2 = { term_label: 'Universe::Galaxy::Planet' }
      item3 = { term_label: 'Universe' }
      item4 = { term_label: 'Universe::Galaxy' }
      item5 = { term_label: 'Universe::Galaxy::Ketchup' }
      item6 = { term_label: 'Bizarro::World' }
      item7 = { term_label: 'Bizarro' }
      expect(described_class).to(
        receive(:with_active_extraction_for)
          .and_yield(item1)
          .and_yield(item2)
          .and_yield(item3)
          .and_yield(item4)
          .and_yield(item5)
          .and_yield(item6)
          .and_yield(item7)
      )
      roots = described_class.active_hierarchical_roots(predicate_name: 'administrative_units')

      expect(roots.map(&:term_label)).to match_array([item3.fetch(:term_label), item7.fetch(:term_label)])

      expect(roots.first.children.size).to(eq(2), 'Universe has two children')
      expect(roots.first.children.map(&:term_label)).to eq([item4.fetch(:term_label), item1.fetch(:term_label)])
      expect(
        roots.first.children.find { |node| node.term_label == 'Universe::Galaxy' }.children.map(&:term_label)
      ).to eq([item5.fetch(:term_label), item2.fetch(:term_label)])
      expect(roots.first.children.find { |node| node.term_label == 'Universe::Non-Galactic' }.children.map(&:term_label)).to eq([])

      expect(roots.last.children.size).to(eq(1), 'Bizarro has one child')
      expect(roots.last.children.map(&:term_label)).to eq([item6.fetch(:term_label)])
    end

    it 'fails if we have empty spaces between our nodes' do
      item1 = { term_label: 'Universe::Galaxy::Planet::Continent' }
      item2 = { term_label: 'Universe' }
      expect(described_class).to receive(:with_active_extraction_for).and_yield(item1).and_yield(item2)
      expect { described_class.active_hierarchical_roots(predicate_name: 'administrative_units') }.to(
        raise_error(Locabulary::Exceptions::MissingHierarchicalParentError)
      )
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
