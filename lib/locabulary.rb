require 'date'
require 'json'

module Locabulary
  VERSION='0.1.0'.freeze
  DATA_DIRECTORY = File.expand_path("../../data/", __FILE__).freeze

  class RuntimeError < ::RuntimeError
  end

  class Item
    include Comparable
    ATTRIBUTE_NAMES = [:predicate_name, :term_label, :term_uri, :default_presentation_sequence, :activated_on, :deactivated_on].freeze

    attr_reader *ATTRIBUTE_NAMES

    def initialize(attributes = {})
      ATTRIBUTE_NAMES.each do |key|
        value = attributes.fetch(key) { attributes.fetch(key.to_s, nil) }
        send("#{key}=", value)
      end
    end

    def <=>(other)
      value = default_presentation_sequence <=> other.default_presentation_sequence
      return value unless value == 0
      term_label <=> other.term_label
    end

    private

    attr_writer *ATTRIBUTE_NAMES
  end

  module_function

  # A concession about the as_of; This is not a live query. The data has a low
  # churn rate. And while the date is important, I'm not as concerned about the
  # local controlled vocabulary exposing a date that has expired. When we next
  # deploy the server changes, the deactivated will go away.
  def active_items_for(predicate_name:, as_of: Date.today)
    active_cache[predicate_name] ||= begin
      filename = filename_for_predicate_name(predicate_name: predicate_name)
      JSON.parse(File.read(filename)).each_with_object([]) do |item_values, mem|
        activated_on = Date.parse(item_values.fetch('activated_on'))
        next unless activated_on < as_of
        deactivated_on_value = item_values.fetch('deactivated_on')
        if deactivated_on_value.nil?
          mem << Item.new(item_values)
        else
          deactivated_on = Date.parse(deactivated_on_value)
          next unless deactivated_on >= as_of
          mem << Item.new(item_values)
        end
        mem
      end.sort
    end
  end

  def active_labels_for(predicate_name:, as_of: Date.today)
    active_items_for(predicate_name: predicate_name, as_of: as_of).map(&:term_label)
  end

  def filename_for_predicate_name(predicate_name:)
    filename = File.join(DATA_DIRECTORY, "#{File.basename(predicate_name)}.json")
    return filename if File.exist?(filename)
    raise Locabulary::RuntimeError, "Unable to find predicate_name: #{predicate_name}"
  end

  def active_cache
    @active_cache ||= {}
  end

  def reset_active_cache!
    @active_cache = nil
  end
end
