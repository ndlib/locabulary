module Locabulary
  # Container for all exceptions in the Locabulary ecosystem
  module Exceptions
    class RuntimeError < ::RuntimeError
    end

    # There was a problem finding an item
    class ItemNotFoundError < RuntimeError
      def initialize(predicate_name, label, value)
        super("Unable to find label=#{label.inspect} with value=#{value.inspect} for predicate_name=#{predicate_name.inspect}")
      end
    end

    # An error occurred in attempting to find a given predicate_name in the data store
    class MissingPredicateNameError < RuntimeError
    end

    # There is a problem with the hierarchy; A child is being defined without a defined parent.
    class MissingHierarchicalParentError < RuntimeError
      attr_reader :predicate_name, :error, :item
      def initialize(predicate_name, error, item = nil)
        @predicate_name = predicate_name
        @error = error
        @item = item
        message = ["Expected #{predicate_name.inspect} to have a welformed tree."]
        message << "With item #{item.inspect}." if item
        message << "Error: #{error}"
        super(message.join(" "))
      end
    end
  end
end
