require 'date'
require 'json'

# @since 0.1.0
module Locabulary
  VERSION='0.1.2'.freeze
  DATA_DIRECTORY = File.expand_path("../../data/", __FILE__).freeze

  class RuntimeError < ::RuntimeError
  end

  class Item
    include Comparable
    ATTRIBUTE_NAMES = [:predicate_name, :term_label, :term_uri, :default_presentation_sequence, :activated_on, :deactivated_on].freeze

    attr_reader(*ATTRIBUTE_NAMES)

    def initialize(attributes = {})
      ATTRIBUTE_NAMES.each do |key|
        value = attributes.fetch(key) { attributes.fetch(key.to_s, nil) }
        send("#{key}=", value)
      end
    end

    SORT_SEQUENCE_FOR_NIL = 100_000_000
    def <=>(other)
      value = presentation_sequence <=> other.presentation_sequence
      return value unless value == 0
      term_label <=> other.term_label
    end

    def presentation_sequence
      default_presentation_sequence || SORT_SEQUENCE_FOR_NIL
    end

    private

    attr_writer(*ATTRIBUTE_NAMES)
  end

  module_function

  # @api public
  # @since 0.1.0
  #
  # @note A concession about the as_of; This is not a live query. The data has a
  #   low churn rate. And while the date is important, I'm not as concerned
  #   about the local controlled vocabulary exposing a date that has expired.
  #   When we next deploy the server changes, the deactivated will go away.
  def active_items_for(options = {})
    predicate_name = options.fetch(:predicate_name)
    as_of = options.fetch(:as_of) { Date.today }
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

  # @api public
  # @since 0.1.0
  def active_label_for_uri(options = {})
    predicate_name = options.fetch(:predicate_name)
    term_uri = options.fetch(:term_uri)
    object = active_items_for(predicate_name: predicate_name).detect { |obj| obj.term_uri == term_uri }
    return object.term_label if object
    term_uri
  end

  # @api public
  # @since 0.1.0
  def active_labels_for(options = {})
    predicate_name = options.fetch(:predicate_name)
    active_items_for(predicate_name: predicate_name).map(&:term_label)
  end

  # @api private
  def filename_for_predicate_name(options = {})
    predicate_name = options.fetch(:predicate_name)
    filename = File.join(DATA_DIRECTORY, "#{File.basename(predicate_name)}.json")
    return filename if File.exist?(filename)
    raise Locabulary::RuntimeError, "Unable to find predicate_name: #{predicate_name}"
  end

  # @api private
  def active_cache
    @active_cache ||= {}
  end

  # @api private
  def reset_active_cache!
    @active_cache = nil
  end
end
