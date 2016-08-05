module Locabulary
  # Container for all exceptions in the Locabulary ecosystem
  module Exceptions
    class RuntimeError < ::RuntimeError
    end

    # There was a problem finding an item
    class ItemNotFoundError < RuntimeError
      def initialize(predicate_name, label)
        super("Unable to find label=#{label.inspect} for predicate_name=#{predicate_name.inspect}")
      end
    end

    # An error occurred in attempting to find a given predicate_name in the data store
    class MissingPredicateNameError < RuntimeError
    end

    # There is a problem with the hierarchy; A child is being defined without a defined parent.
    class MissingHierarchicalParentError < RuntimeError
      attr_reader :predicate_name, :error
      def initialize(predicate_name, error)
        @predicate_name = predicate_name
        @error = error
        super("Expected #{predicate_name.inspect} to have a welformed tree. Error: #{error}")
      end
    end
  end
end
