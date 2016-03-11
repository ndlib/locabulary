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

  context '.active_nested_labels_for' do
    it 'will handle a single level deep' do
      result = Locabulary.active_nested_labels_for(predicate_name: 'administrative_units')
      obtained_result = result.fetch('University of Notre Dame')
      expected_result = ['University of Notre Dame']
      expect(obtained_result).to eq(expected_result)
    end

    it 'will handle a nesting two levels deep' do
      result = Locabulary.active_nested_labels_for(predicate_name: 'administrative_units')
      obtained_result = result.fetch("University of Notre Dame::Law School")
      expected_result = ["Law School"]
      expect(obtained_result).to eq(expected_result)
    end

    it 'will handle a nesting three levels deep' do
      result = Locabulary.active_nested_labels_for(predicate_name: 'administrative_units')
      obtained_result = result.fetch("University of Notre Dame::Hesburgh Libraries")
      expected_result = ["Hesburgh Libraries", "Rare Books and Special Collections", "University Archives"]
      expect(obtained_result).to eq(expected_result)
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
