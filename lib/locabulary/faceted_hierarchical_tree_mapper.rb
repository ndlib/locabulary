require 'locabulary/facet_wrapper_for_item'
require 'active_support/core_ext/hash/except'

module Locabulary
  # @since 0.5.0
  #
  # Responsible for mapping a faceted tree into a hierarchical tree that has sorted children.
  class FacetedHierarchicalTreeMapper
    # @param options [Hash]
    # @option tree [Hash] - See the specs for the expected structure of the tree
    # @option predicate_name [String]
    def initialize(options = {})
      @tree = options.fetch(:tree)
      @predicate_name = options.fetch(:predicate_name)
    end

    # Maps the existing :tree and its open data structure into a more well-formed sorted array of proper objects.
    #
    # @return [Array<Locabulary::FacetWrapperForItem] A sorted array of top level nodes, each of which has child nodes
    def call
      nodes = []
      tree.each_value do |facet_branch|
        nodes << build_node_for(facet_branch)
      end
      nodes.sort
    end

    private

    attr_reader :tree, :predicate_name

    def build_node_for(facet_branch)
      faceted_node = facet_branch.fetch(:_)
      node = new_node(faceted_node)
      facet_branch.except(:_).each_value do |facet_sub_branch|
        child_node = build_node_for(facet_sub_branch)
        node.add_child(child_node)
      end
      node
    end

    def new_node(faceted_node)
      term_label = convert_faceted_node_to_term_label(faceted_node)
      item = find_locabulary_item_for(term_label)
      if item
        FacetWrapperForItem.build_for_faceted_node_and_locabulary_item(faceted_node: faceted_node, locabulary_item: item)
      else
        FacetWrapperForItem.build_for_faceted_node(faceted_node: faceted_node, predicate_name: predicate_name, term_label: term_label)
      end
    end

    def find_locabulary_item_for(term_label)
      items = Locabulary.active_items_for(predicate_name: predicate_name)
      items.find do |item|
        item.term_label == term_label
      end
    end

    def convert_faceted_node_to_term_label(faceted_node)
      faceted_node.qvalue.gsub(/(?<!:):(?!:)/, "::")
    end
  end
end
