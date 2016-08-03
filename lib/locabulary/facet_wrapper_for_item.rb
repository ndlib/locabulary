require 'forwardable'
require 'delegate'

module Locabulary
  # A wrapper for a Locabulary::Item::Base that includes information from
  # the SOLR query.
  class FacetWrapperForItem < SimpleDelegator
    # @api public
    # @since 0.5.0
    #
    # In some cases, we may have a facet with a term_label that is not found in the existing data storage.
    # Instead of throwing an exception, we can make a reasonable approximation for that item based on the given parameters.
    #
    # @see Locabulary::FacetedHierarchicalTreeSorter
    #
    # @param options [Hash]
    # @option predicate_name [String]
    # @option faceted_node [#qvalue, #value, #hits]
    # @option term_label [String]
    # @return Locabulary::FacetWrapperForItem
    def self.build_for_faceted_node(options = {})
      predicate_name = options.fetch(:predicate_name)
      faceted_node = options.fetch(:faceted_node)
      term_label = options.fetch(:term_label)
      locabulary_item = Locabulary::Items.build(predicate_name: predicate_name, term_label: term_label, default_presentation_sequence: nil)
      new(faceted_node: faceted_node, locabulary_item: locabulary_item)
    end

    # @api public
    # @since 0.5.0
    #
    # In some cases, we have a facet and a locabulary item and this is the public method for building the wrapped object.
    #
    # @see Locabulary::FacetedHierarchicalTreeSorter
    # @param options [Hash]
    # @option predicate_name [String]
    # @option faceted_node [#qvalue, #value, #hits]
    # @option term_label [String]
    # @return Locabulary::FacetWrapperForItem
    def self.build_for_faceted_node_and_locabulary_item(options = {})
      new(options)
    end

    # Don't access .new directly; Use the above builders
    private_class_method :new

    def initialize(options = {})
      @__faceted_node__ = options.fetch(:faceted_node)
      @__locabulary_item__ = options.fetch(:locabulary_item)
      super(@__locabulary_item__)
    end

    attr_reader :__faceted_node__, :__locabulary_item__

    extend Forwardable
    def_delegators :__faceted_node__, :qvalue, :value, :hits
  end
end