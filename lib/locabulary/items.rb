require 'locabulary/item'
require 'hanami/utils/string'
module Locabulary
  # A container for the various types of Locabulary Items
  module Items
    module_function

    # @api public
    # @since 0.2.1
    #
    # @param options [Hash]
    # @option predicate_name [String] Used for lookup of the correct Locabulary::Item type
    def builder_for(options = {})
      predicate_name = options.fetch(:predicate_name)
      possible_class_name_for_predicate_name = Hanami::Utils::String.new(predicate_name).singularize.classify
      klass = begin
        Items.const_get(possible_class_name_for_predicate_name)
      rescue NameError
        Item
      end
      klass.method(:new)
    end
  end
end
require 'locabulary/items/administrative_unit'
