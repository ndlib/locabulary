require 'dry/validation'
require 'dry/validation/schema'

module Locabulary
  class Schema < Dry::Validation::Schema
    key(:predicate_name) { |predicate_name| predicate_name.format?(/\A[a-z_]+\Z/) & predicate_name.filled? }
    key(:values) do |values|
      values.array? do
        values.each do |value|
          value.hash? do
            value.key(:term_label) { |term_label| term_label.filled? }
            value.optional(:term_uri) { |term_label| term_label.none? | term_label.str?  }
            value.optional(:default_presentation_sequence) do |default_presentation_sequence|
              default_presentation_sequence.none? | default_presentation_sequence.int?
            end
            value.key(:activated_on) { |activated_on| activated_on.format?(/\A\d{4}-\d{2}-\d{2}\Z/) }
            value.optional(:deactivated_on) { |deactivated_on| deactivated_on.none? | deactivated_on.format?(/\A\d{4}-\d{2}-\d{2}\Z/) }
          end
        end
      end
    end
  end
end
