require 'set'
require 'date'
require 'locabulary/item'
require 'locabulary/exceptions'
require 'locabulary/hierarchy_processor'

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
        @locabulary_item_class = Item.class_to_instantiate(predicate_name: predicate_name)
        @utility_service = options.fetch(:utility_service) { default_utility_service }
      end

      def call
        HierarchyProcessor.call(
          enumerator: data_enumerator,
          item_builder: item_builder,
          predicate_name: predicate_name
        )
      end

      private

      def data_enumerator
        ->(&block) { utility_service.with_active_extraction_for(predicate_name, as_of, &block) }
      end

      def item_builder
        ->(data) { locabulary_item_class.new(data.merge('predicate_name' => predicate_name)) }
      end

      attr_reader :predicate_name, :as_of, :locabulary_item_class, :utility_service

      def default_utility_service
        require 'locabulary/utility'
        Utility
      end
    end
  end
end
