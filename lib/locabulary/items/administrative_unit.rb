require 'locabulary/exceptions'
require 'locabulary/items/base'

module Locabulary
  module Items
    # Responsible for exposing the data structure logic of the Administrative Units
    #
    # @see ./data/administrative_units.json
    class AdministrativeUnit < Locabulary::Items::Base
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
