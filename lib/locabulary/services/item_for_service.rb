require 'date'
require 'locabulary/exceptions'
require 'locabulary/utility'
require 'locabulary/item'

module Locabulary
  # :nodoc:
  module Services
    # @api private
    class ItemForService
      def self.call(options = {})
        new(options).call
      end

      private_class_method :new

      def initialize(options = {})
        @predicate_name = options.fetch(:predicate_name)
        @term_label = options.fetch(:term_label)
        @as_of = options.fetch(:as_of) { Date.today }
      end

      private

      attr_reader :predicate_name, :term_label, :as_of

      public

      def call
        item = nil
        Utility.with_extraction_for(predicate_name) do |data|
          next unless data.fetch('term_label') == term_label
          item = Item.build(data.merge('predicate_name' => predicate_name))
          break if Utility.data_is_active?(data, as_of)
        end
        return item unless item.nil?
        raise Locabulary::Exceptions::ItemNotFoundError.new(predicate_name, term_label)
      end
    end
    private_constant :ItemForService
  end
end
