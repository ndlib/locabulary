require 'locabulary/items/base'
require 'hanami/utils/string'
require 'locabulary/items/administrative_unit'
module Locabulary
  # Responsible for sorting a hierarchical facet tree.
  class AdministrativeUnitSorter
    attr_reader :hierarchial_facet_tree
    def initialize(hierarchial_facet_tree = {})
      @hierarchial_facet_tree = hierarchial_facet_tree
    end

    #This method return sorted locabulary hierarchical tree for given set of administrative_unit items
    def sorted_hierarchical_facets_for
      nodes = []
      hierarchial_facet_tree.each_pair do |key, sub_facets|
        nodes << build_node_for(key, sub_facets)
      end
      nodes
    end

    private

    def build_node_for(_key, sub_facets)
      arr = sub_facets.shift
      key_struct = arr.last
      node = new_node(key_struct)
      return node if sub_facets.is_a?(String)
      sub_facets.each_pair do |_sub_key, sub_sub_facets|
        child_node = build_node_for(sub_sub_facets.fetch(:_), sub_sub_facets)
        node.add_child(child_node)
      end
      node.sort_children
      node
    end

    def new_node(solr_facet_struct)
      items = Locabulary.active_items_for(predicate_name: "administrative_units")
      term_label=solr_facet_struct.qvalue.gsub(/(?<!:):(?!:)/, "::")
      items.each do |administrative_unit|
        if administrative_unit.term_label == term_label
          return administrative_unit
        end
      end
      solr_facet_struct
    end
  end
end
