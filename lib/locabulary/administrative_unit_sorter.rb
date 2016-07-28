require 'locabulary/items/base'
require 'hanami/utils/string'
require 'locabulary/items/administrative_unit'

module Locabulary

  class AdministrativeUnitSorter
    # For the given input
    # {"University of Notre Dame"=>
    #  {"University of Notre Dame:Hesburgh Libraries" => "Hesburgh Libraries",
    #   "University of Notre Dame:Centers and Institutes" =>
    #       {"University of Notre Dame::Centers and Institutes::Center for Digital Scholarship" => "Center for Digital Scholarship",
    #       "University of Notre Dame::Centers and Institutes::Center for Environmental Science and Technology" => "Center for Environmental Science and Technology",
    #       "University of Notre Dame::Centers and Institutes::Center for Ethics and Culture" => "Center for Ethics and Culture",
    #       "University of Notre Dame::Centers and Institutes::Center for Ethics and Religious Values in Business" => "Center for Ethics and Religious Values in Business",
    #       "University of Notre Dame::Centers and Institutes::Center for Building Communities" => "Center for Building Communities"},
    #   "University of Notre Dame:School of Architecture" => "School of Architecture",
    #   "University of Notre Dame:College of Arts and Letters" => "College of Arts and Letters",
    #   "University of Notre Dame:Mendoza College of Business" => "Mendoza College of Business",
    #   "University of Notre Dame:First Year of Studies" =>"First Year of Studies"}
    # }
    attr_reader :unsorted_facet_tree
    def initialize(unsorted_facet_tree = {})
      @unsorted_facet_tree = unsorted_facet_tree
    end

    #This method return sorted locabulary hierarchical tree for given set of administrative_unit items
    def sorted_hierarchical_facets_for
      nodes = []
      unsorted_facet_tree.each_pair do |key, sub_facets|
        nodes << build_node_for(key, sub_facets)
      end
      nodes
    end

    def build_node_for(value , sub_facets)
      node = new_node(value)
      unless sub_facets.is_a?(String)
        sub_facets.each_pair do |subvalue, sub_sub_facets|
          node.add_child(build_node_for(subvalue, sub_sub_facets))
        end
        node.sort_children
      end
      node
    end

    def new_node(value)
      items = Locabulary.active_items_for(predicate_name: "administrative_units")
      term_label=value.gsub(/(?<!:):(?!:)/, "::")
      items.each do |administrative_unit|
        if administrative_unit.term_label == term_label
          return administrative_unit
        end
      end
      value
    end
  end


end
