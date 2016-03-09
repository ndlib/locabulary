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
    end
  end
end
