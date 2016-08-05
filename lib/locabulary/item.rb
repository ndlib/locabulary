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
      class_to_instantiate(predicate_name: predicate_name).new(attributes)
    end

    # @api public
    # @since 0.2.1
    # @deprecated 0.6.0 Prefer instead class_to_instantiate
    #
    # Responsible for finding the appropriate Factory method for building a Locabulary::Item
    #
    # @param options [Hash]
    # @option predicate_name [String] Used for lookup of the correct Locabulary::Item type
    # @return [#call] A builder method (`.new` for the given constant)
    def self.builder_for(options = {})
      class_to_instantiate(options).method(:new)
    end

    # @api public
    # @since 0.5.1
    #
    # Responsible for finding the appropriate class that will be instantiated
    #
    # @param options [Hash]
    # @option options [String] :predicate_name Used for lookup of the correct Locabulary::Item type
    # @return [Locabulary::Items::Base]
    def self.class_to_instantiate(options = {})
      predicate_name = options.fetch(:predicate_name)
      possible_class_name_for_predicate_name = predicate_name.singularize.classify
      begin
        Items.const_get(possible_class_name_for_predicate_name)
      rescue NameError
        Items::Base
      end
    end
  end
end
