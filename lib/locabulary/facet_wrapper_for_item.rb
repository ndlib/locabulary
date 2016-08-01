require 'forwardable'
require 'delegate'

module Locabulary
  # A wrapper for a Locabulary::Item::Base that includes information from
  # the SOLR query.
  class FacetWrapperForItem < SimpleDelegator
    def initialize(options = {})
      @faceted_node = options.fetch(:faceted_node)
      super(options.fetch(:locabulary_item))
    end

    extend Forwardable
    def_delegators :@faceted_node, :qvalue, :value, :hits
  end
end
