require 'active_support/core_ext/string/inflections'
require 'locabulary/services/build_ordered_hierarchical_tree_service'
require 'locabulary/services/active_items_for_service'
require 'locabulary/services/active_hierarchical_roots_service'
require 'locabulary/services/item_for_service'
require 'locabulary/services/all_items_for_service'
require 'locabulary/services/hierarchical_menu_options'

# :nodoc:
module Locabulary
  # @api private
  #
  # A container namespace for service style objects; These service objects are
  # responsible for encapsulating logic related to interaction with the data
  # storage.
  module Services
    # @api private
    # @since 0.6.1
    #
    # Responsible for delegating messages to underlying class.
    # This indirection is used to protect the direct to private classes and thus
    # keep a tightly defined interface.
    #
    # @param command_name [Symbol]
    # @param options [Hash]
    def self.call(command_name, options = {})
      command_class_name = "#{command_name}_service".classify
      klass = "Locabulary::Services::#{command_class_name}".constantize
      klass.call(options)
    end
  end
  private_constant :Services
end
