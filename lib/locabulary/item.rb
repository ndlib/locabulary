module Locabulary
  # A singular item in the controlled vocubulary.
  # @see https://en.wikipedia.org/wiki/Resource_Description_Framework
  class Item
    # [String] the trait for a given subject that we are describing by way of the term_label/term_uri
    attr_reader :predicate_name

    # [String] the human friendly version of the meaning for this given trait
    # @note For the time being, please regard the term_label as immutable; If you need a modification, deactivate this one and activate a
    #    new one
    attr_reader :term_label

    # [String] the machine friendly version of the meaning for this given trait
    # @note For the time being, please regard the term_uri as immutable; If you need a modification, deactivate this one and activate a new
    #    one
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

    # @deprecated
    attr_reader :deposit_label

    # @deprecated
    attr_reader :grouping

    # @deprecated
    attr_reader :affiliation

    def initialize(attributes = {})
      ATTRIBUTE_NAMES.each do |key|
        value = attributes.fetch(key) { attributes.fetch(key.to_s, nil) }
        send("#{key}=", value)
      end
    end

    ATTRIBUTE_NAMES = [
      :predicate_name, :term_label, :term_uri, :deposit_label, :description, :grouping, :affiliation, :default_presentation_sequence,
      :activated_on, :deactivated_on
    ].freeze

    def to_h
      ATTRIBUTE_NAMES.each_with_object({}) do |key, mem|
        mem[key.to_s] = send(key) unless send(key).to_s.strip == ''
        mem
      end
    end
    alias as_json to_h

    def to_persistence_format_for_fedora
      return term_uri unless term_uri.to_s.strip == ''
      term_label
    end

    private

    attr_writer(*ATTRIBUTE_NAMES)

    def predicate_name=(input)
      @predicate_name = input.to_s
    end

    public

    include Comparable

    def <=>(other)
      predicate_name_sort = predicate_name <=> other.predicate_name
      return predicate_name_sort unless predicate_name_sort == 0
      presentation_sequence_sort = presentation_sequence <=> other.presentation_sequence
      return presentation_sequence_sort unless presentation_sequence_sort == 0
      term_label <=> other.term_label
    end

    SORT_SEQUENCE_FOR_NIL = 100_000_000
    private_constant :SORT_SEQUENCE_FOR_NIL
    def presentation_sequence
      default_presentation_sequence || SORT_SEQUENCE_FOR_NIL
    end
  end
end
