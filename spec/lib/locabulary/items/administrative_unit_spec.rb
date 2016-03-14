require 'spec_helper'
require 'locabulary/items/administrative_unit'

RSpec.describe Locabulary::Items::AdministrativeUnit do
  subject { described_class.new }
  its(:attribute_names) { should include(:predicate_name) }
  its(:attribute_names) { should include(:term_label) }
  its(:attribute_names) { should include(:term_uri) }
  its(:attribute_names) { should include(:description) }
  its(:attribute_names) { should include(:grouping) }
  its(:attribute_names) { should include(:affiliation) }
  its(:attribute_names) { should include(:default_presentation_sequence) }
  its(:attribute_names) { should include(:activated_on) }
  its(:attribute_names) { should include(:deactivated_on) }

  context 'slug methods' do
    subject { Locabulary::Items::AdministrativeUnit.new(term_label: 'Universe::Galaxy::Planet') }

    its(:root_slug) { should eq('Universe') }
    its(:parent_slugs) { should eq(%w(Universe Galaxy)) }
    its(:slugs) { should eq(%w(Universe Galaxy Planet)) }
    its(:parent_term_label) { should eq('Universe::Galaxy') }
  end
end
