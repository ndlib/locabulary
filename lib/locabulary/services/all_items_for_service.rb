require 'date'
require 'locabulary/item'
require 'locabulary/utility'

module Locabulary
  # :nodoc:
  module Services
    # @api private
    #
    # Responsible for extracting a non-hierarchical sorted array of Locabulary::Item for the given predicate_name
    #
    # @see Locabulary::Item
    class AllItemsForService
      def self.cache
        @cache ||= {}
      end
      private_class_method :cache

      # @api private
      # @since 0.7.0
      def self.reset_cache!
        @cache = {}
      end

      # @api private
      # @since 0.7.0
      #
      # @param options [Hash]
      # @option options [String] :predicate_name
      def self.call(options = {})
        predicate_name = options.fetch(:predicate_name)
        cache[predicate_name] ||= new(options).call
      end

      private_class_method :new

      def initialize(options = {})
        @predicate_name = options.fetch(:predicate_name)
        @builder = Item.builder_for(predicate_name: predicate_name)
      end

      def call
        collector = []
        Utility.with_extraction_for(predicate_name) do |data|
          collector << builder.call(data.merge('predicate_name' => predicate_name))
        end
        collector.sort
      end

      private

      attr_reader :predicate_name, :as_of, :builder
    end
    private_constant :ActiveItemsForService
  end
end
