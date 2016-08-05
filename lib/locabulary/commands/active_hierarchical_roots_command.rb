require 'set'
require 'date'
require 'locabulary/items'
require 'locabulary/exceptions'

module Locabulary
  module Commands
    # Responsible for transforming the flat data for the given :predicate_name
    # into a hierarchy.
    class ActiveHierarchicalRootsCommand
      def self.cache
        @cache ||= {}
      end
      private_class_method :cache

      # @api private
      def self.reset_cache!
        @cache = {}
      end

      # @api private
      # @since 0.5.0
      #
      # @param options [Hash]
      # @option options [String] :predicate_name
      # @option options [Date] :as_of (Date.today)
      #
      # @note A concession about the as_of; This is not a live Utility. The data has a
      #   low churn rate. And while the date is important, I'm not as concerned
      #   about the local controlled vocabulary exposing a date that has expired.
      #   When we next deploy the server changes, the deactivated will go away.
      def self.call(options = {})
        predicate_name = options.fetch(:predicate_name)
        cache[predicate_name] ||= new(options).call
      end

      def initialize(options = {})
        @predicate_name = options.fetch(:predicate_name)
        @as_of = options.fetch(:as_of) { Date.today }
        @builder = Item.builder_for(predicate_name: predicate_name)
        @utility_service = options.fetch(:utility_service) { default_utility_service }
      end

      def call
        items = []
        hierarchy_graph_keys = {}
        top_level_slugs = Set.new
        utility_service.with_active_extraction_for(predicate_name, as_of) do |data|
          item = builder.call(data.merge('predicate_name' => predicate_name))
          items << item
          top_level_slugs << item.root_slug
          hierarchy_graph_keys[item.term_label] = item
        end
        associate_parents_and_childrens_for(hierarchy_graph_keys, items)
        top_level_slugs.map { |slug| hierarchy_graph_keys.fetch(slug) }
      end

      private

      attr_reader :predicate_name, :as_of, :builder, :utility_service

      def default_utility_service
        require 'locabulary/utility'
        Utility
      end

      def associate_parents_and_childrens_for(hierarchy_graph_keys, items)
        items.each do |item|
          begin
            hierarchy_graph_keys.fetch(item.parent_term_label).add_child(item) unless item.parent_slugs.empty?
          rescue KeyError => error
            raise Exceptions::MissingHierarchicalParentError.new(predicate_name, error)
          end
        end
      end
    end
  end
end
