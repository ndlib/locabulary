require 'set'
require 'locabulary'
require 'locabulary/exceptions'
require 'locabulary/item'
require 'locabulary/facet_wrapper_for_item'
require 'locabulary/hierarchy_processor'

module Locabulary
  # :nodoc:
  module Services
    # @api private
    #
    # Responsible for building a hierarchical tree from faceted items, and ordering the nodes as per the presentation sequence for the
    # associated predicate_name.
    class BuildOrderedHierarchicalTreeCommand
      # @api private
      # @since 0.5.0
      #
      # @param options [Hash]
      # @option options [String] :predicate_name
      # @option options [Array<#hits, #value>] :faceted_items
      # @option options [String] :faceted_item_hierarchy_delimiter
      #                          For any given item in faceted_items how is the hierarchy encoded in the :value?
      #
      # @return [Array<FacetWrapperForItem>]
      def self.call(options = {})
        new(options).call
      end

      private_class_method :new

      def initialize(options = {})
        @predicate_name = options.fetch(:predicate_name)
        @faceted_items = options.fetch(:faceted_items)
        @faceted_item_hierarchy_delimiter = options.fetch(:faceted_item_hierarchy_delimiter)
        @locabulary_item_class = Item.class_to_instantiate(predicate_name: predicate_name)
      end

      def call
        HierarchyProcessor.call(
          enumerator: faceted_items.method(:each),
          item_builder: method(:build_item),
          predicate_name: predicate_name
        )
      end

      private

      attr_reader :locabulary_item_class, :predicate_name, :faceted_items, :faceted_item_hierarchy_delimiter

      def build_item(faceted_node)
        term_label = convert_faceted_node_value_to_term_label(faceted_node.value)
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

      # Responsible for converting the hierarchy delimiter of the facet item to the hierarchy delimiter of the Locabulary::Item.
      def convert_faceted_node_value_to_term_label(value)
        value.split(faceted_item_hierarchy_delimiter).join(locabulary_item_class.hierarchy_delimiter)
      end
    end
    private_constant :BuildOrderedHierarchicalTreeCommand
  end
end
