require 'dry/configurable'
module Locabulary
  module Items
    # A singular item in the controlled vocubulary.
    # @see https://en.wikipedia.org/wiki/Resource_Description_Framework
    class Base
      extend Dry::Configurable

      setting :attribute_names, %i(
        predicate_name term_label term_uri deposit_label description default_presentation_sequence acronym
        activated_on deactivated_on
      ).freeze

      def attribute_names
        self.class.config.attribute_names
      end

      # [String] the trait for a given subject that we are describing by way of the term_label/term_uri
      attr_reader :predicate_name

      # [String] the human friendly version of the meaning for this given trait
      # @note For the time being, please regard the term_label as immutable; If you need a modification, deactivate this one and activate a
      #    new one
      attr_reader :term_label

      # [String] the machine friendly version of the meaning for this given trait
      # @note For the time being, please regard the term_uri as immutable; If you need a modification, deactivate this one and activate a
      #    new one
      attr_reader :term_uri

      # [String] a side-car of more exhaustive information related to this particular term
      attr_reader :description

      # [Date] When was this particular item activated
      attr_reader :activated_on

      # [Date] When was this particular item deactivated
      attr_reader :deactivated_on

      # [Integer, nil] What is the order in which
      # @see Locabulary::Item#presentation_sequence for details on how this is calculated
      attr_reader :default_presentation_sequence

      # [String, nil] A translation acronym for the term label
      # @note: must be unique, as we search from acronym for a label or vice versa
      attr_reader :acronym

      # @deprecated
      # The label to be used when depositing; This is deprecated in favor of mapping functions.
      # Those mapping functions are in part described in Locabuarly (faceted_item_hierarchy_delimiter).
      attr_reader :deposit_label

      def initialize(attributes = {})
        attribute_names.each do |key|
          value = attributes[key] || attributes[key.to_s]
          send("#{key}=", value)
        end
        @children = []
      end

      # @api private
      def to_h
        attribute_names.each_with_object({}) do |key, mem|
          mem[key.to_s] = send(key) unless send(key).to_s.strip == ''
          mem
        end
      end
      alias as_json to_h

      # @api public
      def to_persistence_format_for_fedora
        return term_uri unless term_uri.to_s.strip == ''
        term_label
      end
      alias id to_persistence_format_for_fedora

      private

      attr_writer(*config.attribute_names)

      def predicate_name=(input)
        @predicate_name = input.to_s
      end

      def default_presentation_sequence=(input)
        @default_presentation_sequence = input.to_s.strip == '' ? nil : input.to_i
      end

      public

      include Comparable

      def <=>(other)
        predicate_name_sort = predicate_name <=> other.predicate_name
        return predicate_name_sort unless predicate_name_sort.zero?
        presentation_sequence_sort = presentation_sequence <=> other.presentation_sequence
        return presentation_sequence_sort unless presentation_sequence_sort.zero?
        term_label <=> other.term_label
      end

      SORT_SEQUENCE_FOR_NIL = 100_000_000
      private_constant :SORT_SEQUENCE_FOR_NIL
      def presentation_sequence
        default_presentation_sequence || SORT_SEQUENCE_FOR_NIL
      end

      # @api public
      def children
        @children.sort
      end

      # @api private
      # Yes, this is private. Its an internal mechanism.
      def add_child(*input)
        @children += input
      end

      HIERARCHY_DELIMITER = '::'.freeze

      # @api public
      def slugs
        term_label.split(HIERARCHY_DELIMITER)
      end

      # @api public
      def self.hierarchy_delimiter
        HIERARCHY_DELIMITER
      end

      # @api public
      def parent_slugs
        slugs[0..-2]
      end

      # @api public
      def parent_term_label
        parent_slugs.join(HIERARCHY_DELIMITER)
      end

      # @api public
      def root_slug
        slugs[0]
      end

      # @api public
      def selectable?
        children.count.zero?
      end

      # @api public
      # When rendered as part of a select list
      def selectable_label
        slugs[-1]
      end

      alias selectable_id id

      # @api public
      # When rendered as part of a facet list
      def hierarchy_facet_label
        slugs[-1]
      end
    end
  end
end
