module Locabulary
  # A singular item in the controlled vocubulary
  class Item
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

    attr_reader(*ATTRIBUTE_NAMES)

    private

    attr_writer(*ATTRIBUTE_NAMES)

    public

    include Comparable

    def <=>(other)
      value = presentation_sequence <=> other.presentation_sequence
      return value unless value == 0
      term_label <=> other.term_label
    end

    SORT_SEQUENCE_FOR_NIL = 100_000_000
    private_constant :SORT_SEQUENCE_FOR_NIL
    def presentation_sequence
      default_presentation_sequence || SORT_SEQUENCE_FOR_NIL
    end
  end
end
