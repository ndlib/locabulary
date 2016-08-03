require 'spec_helper'
require 'locabulary'
require 'locabulary/faceted_hierarchical_tree_sorter'
require 'spec_helper/facetable_struct'

RSpec.describe Locabulary::FacetedHierarchicalTreeSorter do
  let(:tree) do
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
        },
        "College of Wizardry" => {
          _: FacetableStruct.new("University of Notre Dame:College of Wizardry", "College of Wizardry", 25)
        }
      }
    }
  end

  subject { Locabulary::FacetedHierarchicalTreeSorter.new(tree: tree, predicate_name: 'administrative_units') }

  context '#call' do
    it 'should return an array of wrapper objects' do
      mapper = ->(node) { [node.term_label, node.hits] }
      nodes = subject.call
      mapped_nodes = nodes.map(&mapper)
      expect(mapped_nodes).to eq([['University of Notre Dame', 3]])
      mapped_child_nodes = nodes.first.children.map(&mapper)
      expect(mapped_child_nodes).to eq(
        [
          ["University of Notre Dame::College of Arts and Letters", 2],
          ["University of Notre Dame::Mendoza College of Business", 1],
          ["University of Notre Dame::College of Engineering", 1],
          ["University of Notre Dame::College of Wizardry", 25]
        ]
      )

      mapped_grandchild_nodes = nodes.first.children.first.children.map(&mapper)
      expect(mapped_grandchild_nodes).to eq(
        [
          ["University of Notre Dame::College of Arts and Letters::Africana Studies", 1],
          ["University of Notre Dame::College of Arts and Letters::East Asian Languages & Cultures", 1]
        ]
      )
    end
    it 'should handle a missing term by building a basic item from the given facet' do
      tree = {
        "College of Wizardry" => { _: FacetableStruct.new("College of Wizardry", "College of Wizardry", 3) }
      }
      sorter = Locabulary::FacetedHierarchicalTreeSorter.new(tree: tree, predicate_name: 'administrative_units')
      mapped_nodes = sorter.call
      expect(mapped_nodes.first).to be_a(Locabulary::FacetWrapperForItem)
    end
  end
end
