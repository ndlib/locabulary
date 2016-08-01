require 'dry/validation'
require 'dry/validation/schema'

module Locabulary
  # Responsible for providing a defined and clear schema for each of the locabulary items.
  Schema = Dry::Validation.Schema do
    required(:predicate_name).filled(format?: /\A[a-z_]+\Z/)
    required(:values).each do
      required(:term_label).filled(:str?)
      optional(:description).maybe(:str?)
      optional(:grouping).maybe(:str?)
      optional(:affiliation).maybe(:str?)
      optional(:default_presentation_sequence).maybe(:int?)
      required(:activated_on).filled(format?: /\A\d{4}-\d{2}-\d{2}\Z/)
      optional(:deactivated_on).maybe(format?: /\A\d{4}-\d{2}-\d{2}\Z/)
    end
  end
end
