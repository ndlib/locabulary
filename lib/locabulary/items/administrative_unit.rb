# encoding: UTF-8
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
          :predicate_name, :term_label, :term_uri, :description, :grouping, :classification, :affiliation, :default_presentation_sequence,
          :homepage, :activated_on, :deactivated_on
        ]
      end

      # [String] What is the URL of the homepage. Please note the term_uri is reserved for something that is more resolvable by machines.
      #   And while the homepage may look resolvable, it is not as meaningful for longterm preservation.
      attr_reader :homepage
      attr_reader :classification
      attr_reader :grouping
      attr_reader :affiliation

      private

      attr_writer :homepage, :classification, :grouping, :affiliation

      public

      def initialize(*args)
        super
        @children = []
      end

      def children
        @children.sort
      end

      def add_child(*input)
        @children += input
      end

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

      def selectable?
        children.count == 0
      end

      NON_DEPARTMENTAL_SLUG = "Non-Departmental".freeze
      # NOTE: The whitespace characters are "thin spaces", U+200A
      HUMAN_FRIENDLY_HIERARCHY_SEPARATOR = ' — '.freeze
      def selectable_label
        if slugs[-1] == NON_DEPARTMENTAL_SLUG
          slugs[-2..-1].join(HUMAN_FRIENDLY_HIERARCHY_SEPARATOR)
        else
          slugs[-1]
        end
      end

      alias selectable_id id
    end
  end
end
