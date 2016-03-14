require 'date'
require 'json'
require 'locabulary/exceptions'
require 'locabulary/items'

# @since 0.1.0
module Locabulary
  VERSION = '0.2.0'.freeze
  DATA_DIRECTORY = File.expand_path("../../data/", __FILE__).freeze

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
    builder = Items.builder_for(predicate_name: predicate_name)
    active_cache[predicate_name] ||= begin
      collector = []
      with_active_extraction_for(predicate_name, as_of) do |data|
        collector << builder.call(data.merge('predicate_name' => predicate_name))
      end
      collector.sort
    end
  end

  def with_active_extraction_for(predicate_name, as_of)
    filename = filename_for_predicate_name(predicate_name: predicate_name)
    json = JSON.parse(File.read(filename))
    json.fetch('values').each do |data|
      activated_on = Date.parse(data.fetch('activated_on'))
      next unless activated_on < as_of
      deactivated_on_value = data.fetch('deactivated_on', nil)
      if deactivated_on_value.nil?
        yield(data)
      else
        deactivated_on = Date.parse(deactivated_on_value)
        next unless deactivated_on >= as_of
        yield(data)
      end
    end
  end
  private :with_active_extraction_for

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
    raise Locabulary::Exceptions::RuntimeError, "Unable to find predicate_name: #{predicate_name}"
  end

  # @api private
  def active_cache
    @active_cache ||= {}
  end

  # @api private
  def active_hierarchy_cache
    @active_hierarchy_cache ||= {}
  end

  # @api private
  def reset_active_cache!
    @active_cache = nil
    @active_hierarchy_cache = nil
  end
end
