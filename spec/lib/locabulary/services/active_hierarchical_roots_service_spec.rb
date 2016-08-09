require 'spec_helper'
require 'locabulary/services/active_hierarchical_roots_service'

module Locabulary
  module Services
    RSpec.describe ActiveHierarchicalRootsService do
      context '.call' do
        before { described_class.reset_cache! }
        after { described_class.reset_cache! }
        subject { described_class.call(predicate_name: 'administrative_units') }
        it 'works on the existing administrative_units' do
          results = subject
          expect(results).to be_a(Array)
          expect(results.size).to be > 1
          results.each do |result|
            expect(result).to be_a(Locabulary::Items::AdministrativeUnit)
          end
        end

        it 'builds a hierarchical tree with well-formed data' do
          # Pardon for the antics; This method tests the guts of the logic for .active_hierarchical_roots.
          # It is a bit more complicated as it requires mapping hash data to items then querying the children of those built items.
          item1 = { term_label: 'Universe::Non-Galactic' }
          item2 = { term_label: 'Universe::Galaxy::Planet' }
          item3 = { term_label: 'Universe' }
          item4 = { term_label: 'Universe::Galaxy' }
          item5 = { term_label: 'Universe::Galaxy::Ketchup' }
          item6 = { term_label: 'Bizarro::World' }
          item7 = { term_label: 'Bizarro' }
          utility_service = double(with_active_extraction_for: true)
          expect(utility_service).to(
            receive(:with_active_extraction_for)
              .and_yield(item1)
              .and_yield(item2)
              .and_yield(item3)
              .and_yield(item4)
              .and_yield(item5)
              .and_yield(item6)
              .and_yield(item7)
          )
          roots = described_class.call(predicate_name: 'administrative_units', utility_service: utility_service)

          expect(roots.map(&:term_label)).to match_array([item3.fetch(:term_label), item7.fetch(:term_label)])
          expect(roots.last.children.size).to(eq(2), 'Universe has two children')
          expect(roots.last.children.map(&:term_label)).to eq([item4.fetch(:term_label), item1.fetch(:term_label)])
          expect(
            roots.last.children.find { |node| node.term_label == 'Universe::Galaxy' }.children.map(&:term_label)
          ).to eq([item5.fetch(:term_label), item2.fetch(:term_label)])
          expect(roots.last.children.find { |node| node.term_label == 'Universe::Non-Galactic' }.children.map(&:term_label)).to eq([])

          expect(roots.first.children.size).to(eq(1), 'Bizarro has one child')
          expect(roots.first.children.map(&:term_label)).to eq([item6.fetch(:term_label)])
        end

        it 'fails if we have empty spaces between our nodes' do
          utility_service = double(with_active_extraction_for: true)

          item1 = { term_label: 'Universe::Galaxy::Planet::Continent' }
          item2 = { term_label: 'Universe' }
          expect(utility_service).to receive(:with_active_extraction_for).and_yield(item1).and_yield(item2)
          expect do
            described_class.call(predicate_name: 'administrative_units', utility_service: utility_service)
          end.to(raise_error(Locabulary::Exceptions::MissingHierarchicalParentError))
        end
      end
    end
  end
end
