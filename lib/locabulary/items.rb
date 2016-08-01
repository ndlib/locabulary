require 'locabulary/items/base'
require 'active_support/core_ext/string/inflections'
module Locabulary
  # A container for the various types of Locabulary Items
  module Items
    # @api public
    # @since 0.2.1
    def self.build(options = {})
      predicate_name = options.fetch(:predicate_name) { options.fetch('predicate_name') }
      builder_for(predicate_name: predicate_name).call(options)
    end

    # @api public
    # @since 0.2.1
    #
    # @param options [Hash]
    # @option predicate_name [String] Used for lookup of the correct Locabulary::Item type
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
require 'locabulary/items/administrative_unit'
