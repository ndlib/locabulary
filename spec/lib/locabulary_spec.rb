require 'spec_helper'
require 'locabulary'

RSpec.describe Locabulary do
  before { Locabulary.reset_active_cache! }

  it 'will throw an exception if the predicate name is missing' do
    expect { Locabulary.filename_for_predicate_name(predicate_name: '__missing__') }.to raise_error(Locabulary::Exceptions::RuntimeError)
  end

  it 'will de-reference the filenmae to a base name' do
    expect(Locabulary.filename_for_predicate_name(predicate_name: "../test/copyright")).to(
      eq(File.join(Locabulary::DATA_DIRECTORY, 'copyright.json'))
    )
  end

  context '.active_items_for' do
    it 'will parse the given data' do
      result = Locabulary.active_items_for(predicate_name: 'copyright')
      expect(result.first.term_label).to eq('All rights reserved')
    end
    it 'will build a cached_data' do
      Locabulary.active_items_for(predicate_name: 'copyright')
      expect(Locabulary.active_cache.key?('copyright')).to eq(true)
    end
  end

  context '.active_hierarchical_root' do
    it 'works for administrative_units' do
      expect(Locabulary.active_hierarchical_root(predicate_name: 'administrative_units')).to be_a(Locabulary::Items::AdministrativeUnit)
    end
    it 'builds a hierarchical tree with well-formed data' do
      # Pardon for the antics; This method tests the guts of the logic for .active_hierarchical_root. It is a bit more complicated as it
      # requires mapping hash data to items then querying the children of those built items.
      item1 = { term_label: 'Universe::Non-Galactic' }
      item2 = { term_label: 'Universe::Galaxy::Planet' }
      item3 = { term_label: 'Universe' }
      item4 = { term_label: 'Universe::Galaxy' }
      item5 = { term_label: 'Universe::Galaxy::Ketchup' }
      expect(described_class).to(
        receive(:with_active_extraction_for).and_yield(item1).and_yield(item2).and_yield(item3).and_yield(item4).and_yield(item5)
      )
      root = described_class.active_hierarchical_root(predicate_name: 'administrative_units')

      expect(root.term_label).to(eq(item3.fetch(:term_label)), "with only one item at root level")
      expect(root.children.size).to eq(2)
      expect(root.children.map(&:term_label)).to eq([item1.fetch(:term_label), item4.fetch(:term_label)])
      expect(
        root.children.find { |node| node.term_label == 'Universe::Galaxy' }.children.map(&:term_label)
      ).to eq([item2.fetch(:term_label), item5.fetch(:term_label)])
      expect(root.children.find { |node| node.term_label == 'Universe::Non-Galactic' }.children.map(&:term_label)).to eq([])
    end
    it 'fails if we have more than one root node' do
      item1 = { term_label: 'Apple' }
      item2 = { term_label: 'Orange' }
      expect(described_class).to receive(:with_active_extraction_for).and_yield(item1).and_yield(item2)
      expect { described_class.active_hierarchical_root(predicate_name: 'administrative_units') }.to(
        raise_error(Locabulary::Exceptions::TooManyHierarchicalRootsError)
      )
    end
    it 'fails if we have empty spaces between our nodes' do
      item1 = { term_label: 'Universe::Galaxy::Planet::Continent' }
      item2 = { term_label: 'Universe' }
      expect(described_class).to receive(:with_active_extraction_for).and_yield(item1).and_yield(item2)
      expect { described_class.active_hierarchical_root(predicate_name: 'administrative_units') }.to(
        raise_error(Locabulary::Exceptions::MissingHierarchicalParentError)
      )
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
