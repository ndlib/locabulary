require 'active_support/core_ext/string/inflections'
require 'locabulary/items'

module Locabulary
  # A container of builder methods for items
  module Item
    # @api public
    # @since 0.2.1
    #
    # A Factory method that is responsible for building the appropriate object given a :predicate_name and additional attributes.
    #
    # @param attributes [Hash]
    # @option predicate_name [String]
    # @return [Locabulary::Item]
    # @see Locabulary::Items
    def self.build(attributes = {})
      predicate_name = attributes.fetch(:predicate_name) { attributes.fetch('predicate_name') }
      builder_for(predicate_name: predicate_name).call(attributes)
    end

    # @api public
    # @since 0.2.1
    #
    # Responsible for finding the appropriate Factory method for building a Locabulary::Item
    #
    # @param options [Hash]
    # @option predicate_name [String] Used for lookup of the correct Locabulary::Item type
    # @return [#call] A builder method (`.new` for the given constant)
    def self.builder_for(options = {})
      predicate_name = options.fetch(:predicate_name)
      possible_class_name_for_predicate_name = predicate_name.singularize.classify
      klass = begin
        Items.const_get(possible_class_name_for_predicate_name)
      rescue NameError
        Items::Base
      end
      klass.method(:new)
    end
  end
end
