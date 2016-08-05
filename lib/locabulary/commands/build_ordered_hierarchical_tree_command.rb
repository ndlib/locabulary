require 'set'
require 'locabulary'
require 'locabulary/exceptions'
require 'locabulary/item'
require 'locabulary/facet_wrapper_for_item'

module Locabulary
  module Commands
    # Responsible for building a hierarchical tree from faceted items, and ordering the nodes as per the presentation sequence for the
    # associated predicate_name.
    class BuildOrderedHierarchicalTreeCommand
      # @api private
      # @since 0.5.0
      #
      # @param options [Hash]
      # @option predicate_name [String]
      # @option faceted_items [Array<#hits, #value>]
      # @option faceted_item_hierarchy_delimiter [String]
      #
      # @return [Array<FacetWrapperForItem>]
      def self.call(options = {})
        new(options).call
      end

      def initialize(options = {})
        @predicate_name = options.fetch(:predicate_name)
        @faceted_items = options.fetch(:faceted_items)
        @faceted_item_hierarchy_delimiter = options.fetch(:faceted_item_hierarchy_delimiter)
        @builder = Item.builder_for(predicate_name: predicate_name)
      end

      def call
        items = []
        hierarchy_graph_keys = {}
        top_level_slugs = Set.new
        faceted_items.each do |faceted_item|
          item = build_item(faceted_item)
          items << item
          top_level_slugs << item.root_slug
          hierarchy_graph_keys[item.term_label] = item
        end
        associate_parents_and_childrens_for(hierarchy_graph_keys, items)
        top_level_slugs.map { |slug| hierarchy_graph_keys.fetch(slug) }.sort
      end

      private

      attr_reader :builder, :predicate_name, :faceted_items, :faceted_item_hierarchy_delimiter

      def associate_parents_and_childrens_for(hierarchy_graph_keys, items)
        items.each do |item|
          begin
            hierarchy_graph_keys.fetch(item.parent_term_label).add_child(item) unless item.parent_slugs.empty?
          rescue KeyError => error
            raise Exceptions::MissingHierarchicalParentError.new(predicate_name, error)
          end
        end
      end

      def build_item(faceted_node)
        term_label = faceted_node.value
        locabulary_item = find_locabulary_item(predicate_name: predicate_name, term_label: term_label)
        if locabulary_item
          FacetWrapperForItem.build_for_faceted_node_and_locabulary_item(faceted_node: faceted_node, locabulary_item: locabulary_item)
        else
          FacetWrapperForItem.build_for_faceted_node(faceted_node: faceted_node, predicate_name: predicate_name, term_label: term_label)
        end
      end

      def find_locabulary_item(*args)
        Locabulary.item_for(*args)
      rescue Exceptions::ItemNotFoundError, Exceptions::MissingPredicateNameError
        # Either the predicate name didn't exist or the item didn't exist for the given predicate name
        # Given that we are building from an alternate source, this is an acceptable error. It is possible
        # that we want to consider a developer notification but not abort the whole process.
        nil
      end
    end
  end
end
