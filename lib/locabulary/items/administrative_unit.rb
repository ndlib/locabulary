require 'locabulary/items/base'
module Locabulary
  module Items
    # Responsible for exposing the data structure logic of the Administrative Units
    #
    # @see ./data/administrative_units.json
    class AdministrativeUnit < Locabulary::Items::Base
      # @note I'm assuming that I have but one top level node
      def self.hierarchical_root(items = Locabulary.active_items_for(predicate_name: 'administrative_units'))
        return @hierarchical_root if @hierarchical_root
        graph = {}
        items.each do |item|
          graph[item.term_label] = item
        end
        top_slugs = []
        items.each do |item|
          parent_slugs = item.slugs
          parent_slugs.pop
          top_slugs << parent_slugs[0]
          graph[parent_slugs.join(HIERARCHY_SEPARATOR)].children << item unless parent_slugs.empty?
        end
        # fail if top_slugss are more than one
        @hierarchical_root = graph.fetch(top_slugs.first)
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
    end
  end
end
