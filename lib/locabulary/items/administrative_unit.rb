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

      # [String, nil] The type of administrative unit in the hierarchy (e.g. College, Department, University, etc.)
      attr_reader :classification

      # [String, nil] A larger concept that ties units together; "The Humanities" is a grouping for the following:
      #   * "University of Notre Dame::College of Arts and Letters::Africana Studies"
      #   * "University of Notre Dame::College of Arts and Letters::American Studies"
      attr_reader :grouping

      # [String, nil] For centers and institutes, there is often an affiliation to another administrative unit.
      # @example
      #
      #     {
      #      "predicate_name": "administrative_units",
      #      "term_label": "University of Notre Dame::Centers and Institutes::Center for Accounting Research and Education (CARE)",
      #      "classification": "CenterOrInstitute",
      #      "affiliation": "University of Notre Dame::Mendoza College of Business",
      #      "homepage": "http://www3.nd.edu/~carecob/",
      #      "activated_on": "2015-07-22"
      #    }
      attr_reader :affiliation

      private

      attr_writer :homepage, :classification, :grouping, :affiliation

      public

      NON_DEPARTMENTAL_SLUG = "Non-Departmental".freeze
      # NOTE: The whitespace characters are "thin spaces", U+200A
      HUMAN_FRIENDLY_HIERARCHY_DELIMITER = ' — '.freeze
      def selectable_label
        if slugs[-1] == NON_DEPARTMENTAL_SLUG
          slugs[-2..-1].join(HUMAN_FRIENDLY_HIERARCHY_DELIMITER)
        else
          slugs[-1]
        end
      end
    end
  end
end
