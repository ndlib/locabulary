require 'date'
require 'json'
require 'locabulary/exceptions'

# :nodoc:
module Locabulary
  # A service module providing methods that are common and useful for querying the
  # underlying data sources.
  module Utility
    DATA_DIRECTORY = File.expand_path("../../../data/", __FILE__).freeze
    # @api private
    #
    # Extract and yield data for the given :predicate_name from the data storage. Only yield data that is active on the :as_of date
    #
    # @param predicate_name [String]
    # @param as_of [Date]
    # @yield Raw data object that conforms to the Locabulary::Schema definition
    # @see Locabulary::Schema
    def self.with_active_extraction_for(predicate_name, as_of)
      json = JSON.parse(File.read(filename_for_predicate_name(predicate_name)))
      json.fetch('values').each do |data|
        yield(data) if data_is_active?(data, as_of)
      end
    end

    # @api private
    #
    # Extract and yield data for the given :predicate_name from the data storage.
    #
    # @param predicate_name [String]
    # @yield Raw data object that conforms to the Locabulary::Schema definition for a single value
    # @see Locabulary::Schema
    def self.with_extraction_for(predicate_name)
      json = JSON.parse(File.read(filename_for_predicate_name(predicate_name)))
      json.fetch('values').each do |data|
        yield(data)
      end
    end

    # @api private
    #
    # Determines if the data is active or not active
    #
    # @param data [Hash] conforms to the Locabulary::Schema definition for a single value
    # @param as_of [Date]
    # @return [Boolean]
    # @see Locabulary::Schema
    def self.data_is_active?(data, as_of)
      activated_on = Date.parse(data.fetch('activated_on'))
      return false unless activated_on < as_of
      deactivated_on_value = data['deactivated_on']
      return true if deactivated_on_value.nil?
      deactivated_on = Date.parse(deactivated_on_value)
      return false unless deactivated_on >= as_of
      true
    end

    # @api private
    #
    # Returns the filename of the file that contains the data for the given :predicate_name
    #
    # @param predicate_name [String]
    # @return [String] name of file that contains the data for the given predicate
    def self.filename_for_predicate_name(predicate_name)
      filename = File.join(DATA_DIRECTORY, "#{File.basename(predicate_name)}.json")
      return filename if File.exist?(filename)
      raise Locabulary::Exceptions::MissingPredicateNameError, "Unable to find predicate_name: #{predicate_name}"
    end
  end
  private_constant :Utility
end
