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
    class ActiveItemsForCommand
      def self.cache
        @cache ||= {}
      end
      private_class_method :cache

      # @api private
      # @since 0.5.0
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

      private_class_method :new

      def initialize(options = {})
        @predicate_name = options.fetch(:predicate_name)
        @as_of = options.fetch(:as_of) { Date.today }
        @builder = Item.builder_for(predicate_name: predicate_name)
      end

      def call
        collector = []
        Utility.with_active_extraction_for(predicate_name, as_of) do |data|
          collector << builder.call(data.merge('predicate_name' => predicate_name))
        end
        collector.sort
      end

      private

      attr_reader :predicate_name, :as_of, :builder
    end
    private_constant :ActiveItemsForCommand
  end
end
