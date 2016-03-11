require 'locabulary/exceptions'
require 'locabulary/items/base'
module Locabulary
  module Items
    # Responsible for exposing the data structure logic of the Administrative Units
    #
    # @see ./data/administrative_units.json
    class AdministrativeUnit < Locabulary::Items::Base
      # @note I'm assuming that I have but one top level node
      # @note Instead of looping through three times (once to load, once to categorize, and once to tree-ify, move code into Locabulary
      #     as a method that can reuse the instantiation for active items)
      def self.hierarchical_root(items = Locabulary.active_items_for(predicate_name: 'administrative_units'))
        graph = {}
        items.each do |item|
          graph[item.term_label] = item
        end
        top_slugs = Set.new
        items.each do |item|
          top_slugs << item.root_slug
          begin
            graph.fetch(item.parent_term_label).children << item unless item.parent_slugs.empty?
          rescue KeyError => error
            raise Exceptions::MissingHierarchicalParentError.new('administrative_units', error)
          end
        end
        raise Exceptions::TooManyHierarchicalRootsError.new('administrative_units', top_slugs.to_a) if top_slugs.size > 1
        graph.fetch(top_slugs.first)
      end

      configure do |config|
        config.attribute_names = [
          :predicate_name, :term_label, :term_uri, :description, :grouping, :affiliation, :default_presentation_sequence,
          :activated_on, :deactivated_on
        ]
      end

      def initialize(*args)
        super
        @children = []
      end

      attr_reader :children

      HIERARCHY_SEPARATOR = '::'.freeze
      def slugs
        term_label.split(HIERARCHY_SEPARATOR)
      end

      def parent_slugs
        slugs[0..-2]
      end

      def parent_term_label
        parent_slugs.join(HIERARCHY_SEPARATOR)
      end

      def root_slug
        slugs[0]
      end
    end
  end
end
