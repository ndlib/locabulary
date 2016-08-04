require 'date'
require 'json'
require 'locabulary/items'

module Locabulary
  module Command
    # Responsible for extracting a non-hierarchical sorted array of Locabulary::Item for the given predicate_name
    #
    # @see Locabulary::Item
    class ActiveItemsFor
      DATA_DIRECTORY = File.expand_path("../../../../data/", __FILE__).freeze
      def self.cache
        @cache ||= {}
      end
      private_class_method :cache

      def self.reset_cache!
        @cache = {}
      end

      # @api private
      # @since 0.5.0
      #
      # @param options [Hash]
      # @option predicate_name [String]
      # @option as_of [Date]
      def self.call(options = {})
        predicate_name = options.fetch(:predicate_name)
        cache[predicate_name] ||= new(options).call
      end

      def initialize(options = {})
        @predicate_name = options.fetch(:predicate_name)
        @as_of = options.fetch(:as_of) { Date.today }
        @builder = Items.builder_for(predicate_name: predicate_name)
      end

      def call
        collector = []
        with_active_extraction_for do |data|
          collector << builder.call(data.merge('predicate_name' => predicate_name))
        end
        collector.sort
      end

      private

      attr_reader :predicate_name, :as_of, :builder

      def with_active_extraction_for
        json = JSON.parse(File.read(filename_for_predicate_name))
        json.fetch('values').each do |data|
          yield(data) if data_is_active?(data)
        end
      end

      def data_is_active?(data)
        activated_on = Date.parse(data.fetch('activated_on'))
        return false unless activated_on < as_of
        deactivated_on_value = data['deactivated_on']
        return true if deactivated_on_value.nil?
        deactivated_on = Date.parse(deactivated_on_value)
        return false unless deactivated_on >= as_of
        true
      end

      def filename_for_predicate_name
        filename = File.join(DATA_DIRECTORY, "#{File.basename(predicate_name)}.json")
        return filename if File.exist?(filename)
        raise Locabulary::Exceptions::RuntimeError, "Unable to find predicate_name: #{predicate_name}"
      end
    end
  end
end
