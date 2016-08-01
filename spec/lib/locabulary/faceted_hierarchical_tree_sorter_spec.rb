require 'spec_helper'
require 'locabulary/faceted_hierarchical_tree_sorter'

RSpec.describe Locabulary::FacetedHierarchicalTreeSorter do
  before do
    FacetableStruct = Struct.new(:qvalue, :value, :hits)
  end
  after { Object.remove_const(:FacetableStruct) }
  let(:mock_input_hash) do
    {
      "University of Notre Dame" => {
        _: FacetableStruct.new("University of Notre Dame", "University of Notre Dame", 3),
        "College of Engineering" => {
          _: FacetableStruct.new("University of Notre Dame:College of Engineering", "College of Engineering", 1),
          "Electrical Engineering" => {
            _: FacetableStruct.new("University of Notre Dame:College of Engineering:Electrical Engineering", "Electrical Engineering", 1)
          }
        },
        "College of Arts and Letters" => {
          _: FacetableStruct.new("University of Notre Dame:College of Arts and Letters", "College of Arts and Letters", 2),
          "Africana Studies" => {
            _: FacetableStruct.new("University of Notre Dame:College of Arts and Letters:Africana Studies", "Africana Studies", 1)
          },
          "East Asian Languages & Cultures" => {
            _: FacetableStruct.new(
              "University of Notre Dame:College of Arts and Letters:East Asian Languages & Cultures", "East Asian Languages & Cultures", 1
            )
          }
        },
        "Mendoza College of Business" => {
          _: FacetableStruct.new("University of Notre Dame:Mendoza College of Business", "Mendoza College of Business", 1),
          "Finance" => {
            _: FacetableStruct.new("University of Notre Dame:Mendoza College of Business:Finance", "Finance", 1)
          }
        }
      }
    }
  end

  let(:expected_output) do
    {
      "University of Notre Dame" => {
        _: FacetableStruct.new("University of Notre Dame", "University of Notre Dame", 3),
        "College of Arts and Letters" => {
          _: FacetableStruct.new("University of Notre Dame:College of Arts and Letters", "College of Arts and Letters", 2),
          "Africana Studies" => {
            _: FacetableStruct.new("University of Notre Dame:College of Arts and Letters:Africana Studies", "Africana Studies", 1)
          },
          "East Asian Languages & Cultures" => {
            _: FacetableStruct.new(
              "University of Notre Dame:College of Arts and Letters:East Asian Languages & Cultures", "East Asian Languages & Cultures", 1
            )
          }
        },
        "Mendoza College of Business" => {
          _: FacetableStruct.new("University of Notre Dame:Mendoza College of Business", "Mendoza College of Business", 1),
          "Finance" => {
            _: FacetableStruct.new("University of Notre Dame:Mendoza College of Business:Finance", "Finance", 1)
          }
        },
        "College of Engineering" => {
          _: FacetableStruct.new("University of Notre Dame:College of Engineering", "College of Engineering", 1),
          "Electrical Engineering" => {
            _: FacetableStruct.new("University of Notre Dame:College of Engineering:Electrical Engineering", "Electrical Engineering", 1)
          }
        }
      }
    }
  end
end
