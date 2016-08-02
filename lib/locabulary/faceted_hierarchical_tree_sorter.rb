require 'locabulary/facet_wrapper_for_item'
module Locabulary
  # Responsible for sorting a hierarchical facet tree.
  class FacetedHierarchicalTreeSorter
    # @param options [Hash]
    # @option tree [Hash]
    # @option predicate_name [String]
    def initialize(options = {})
      @tree = options.fetch(:tree)
      @predicate_name = options.fetch(:predicate_name)
    end

    # This method return sorted locabulary hierarchical tree for given set of items for the given predicate_name
    def call
      nodes = []
      tree.each_pair do |key, sub_facets|
        nodes << build_node_for(key, sub_facets)
      end
      nodes
    end

    private

    attr_reader :tree, :predicate_name

    def build_node_for(_key, sub_facets)
      arr = sub_facets.shift
      key_struct = arr.last
      node = new_node(key_struct)
      return node if sub_facets.is_a?(String)
      sub_facets.each_pair do |_sub_key, sub_sub_facets|
        child_node = build_node_for(sub_sub_facets.fetch(:_), sub_sub_facets)
        node.add_child(child_node)
      end
      node
    end

    def new_node(solr_facet_struct)
      items = Locabulary.active_items_for(predicate_name: predicate_name)
      term_label = solr_facet_struct.qvalue.gsub(/(?<!:):(?!:)/, "::")
      items.each do |item|
        if item.term_label == term_label
          return FacetWrapperForItem.new(faceted_node: solr_facet_struct, locabulary_item: item)
        end
      end
      raise
    end
  end
end
