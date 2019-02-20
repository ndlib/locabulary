require 'spec_helper'
require 'locabulary/utility'

module Locabulary
  RSpec.describe Utility do
    context '.data_is_active?' do
      let(:as_of) { Date.parse('2015-10-23') }
      it 'returns false if the data not yet activated' do
        expect(described_class.send(:data_is_active?, { 'activated_on' => '2015-11-23' }, as_of)).to eq(false)
      end

      it 'returns false if the data the as of date is after the deactivation date' do
        expect(
          described_class.send(:data_is_active?, { 'activated_on' => '2014-10-23', 'deactivated_on' => '2014-11-23' }, as_of)
        ).to eq(false)
      end

      it 'returns true if the data is activated and does not have a deactivation date' do
        expect(described_class.send(:data_is_active?, { 'activated_on' => '2013-11-23' }, as_of)).to eq(true)
      end

      it 'returns true if the data is activated and the deactivated date has not come to pass' do
        expect(
          described_class.send(:data_is_active?, { 'activated_on' => '2014-10-23', 'deactivated_on' => '2016-11-23' }, as_of)
        ).to eq(true)
      end

      it 'returns false if the activated date and deactivated date are equal' do
        expect(
          described_class.send(:data_is_active?, { 'activated_on' => '2015-10-23', 'deactivated_on' => '2015-10-23' }, as_of)
        ).to eq(false)
      end
    end

    context '.data_was_ever_active?' do
      it 'returns true if there is no deactivated date' do
        expect(described_class.send(:data_was_ever_active?, 'activated_on' => '2015-11-23')).to eq(true)
      end

      it 'returns false if the two dates are the same' do
        expect(described_class.send(:data_was_ever_active?, 'activated_on' => '2015-11-23', 'deactivated_on' => '2015-11-23')).to eq(false)
      end

      it 'returns true if the two dates are not the same' do
        expect(described_class.send(:data_was_ever_active?, 'activated_on' => '2015-10-23', 'deactivated_on' => '2015-12-23')).to eq(true)
      end
    end

    context '.filename_for_predicate_name' do
      it 'will throw an exception if the predicate name is missing' do
        expect { described_class.filename_for_predicate_name('__missing__') }.to(
          raise_error(Locabulary::Exceptions::MissingPredicateNameError)
        )
      end

      it 'will de-reference the filenmae to a base name' do
        expect(described_class.filename_for_predicate_name("../test/copyright")).to(
          eq(File.join(described_class::DATA_DIRECTORY, 'copyright.json'))
        )
      end
    end
  end
end
