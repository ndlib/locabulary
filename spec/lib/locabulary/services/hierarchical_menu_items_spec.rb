require 'spec_helper'
require 'locabulary/services/hierarchical_menu_options'

module Locabulary
  module Services
    RSpec.describe HierarchicalMenuOptionsService do
      let(:roots) { ActiveHierarchicalRootsService.call(predicate_name: 'administrative_units') }

      context '.call' do
        before { described_class.reset_cache! }
        after { described_class.reset_cache! }
        subject { described_class.call(roots: roots) }
        it 'works on the existing administrative_units and is well-formed' do
          results = subject
          expect(results).to be_a(Array)
          expect(results.size).to be > 1
          results.each do |result|
            expect(result).to be_a(Hash)
            expect(result[:category_title]).to be_a(String)
            expect(result[:item]).to be_a(Locabulary::Items::AdministrativeUnit) unless result[:item].nil?
          end
        end
      end
    end
  end
end
