require 'date'
require 'json'
require 'locabulary/exceptions'
require 'locabulary/items'

# @since 0.1.0
module Locabulary
  DATA_DIRECTORY = File.expand_path("../../data/", __FILE__).freeze

  # @api public
  # @since 0.1.0
  #
  # @note A concession about the as_of; This is not a live query. The data has a
  #   low churn rate. And while the date is important, I'm not as concerned
  #   about the local controlled vocabulary exposing a date that has expired.
  #   When we next deploy the server changes, the deactivated will go away.
  def self.active_items_for(options = {})
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

  # @api public
  # @since 0.4.0
  def self.active_hierarchical_roots(options = {})
    predicate_name = options.fetch(:predicate_name)
    as_of = options.fetch(:as_of) { Date.today }
    builder = Items.builder_for(predicate_name: predicate_name)
    active_hierarchical_root_caches[predicate_name] ||= begin
      items = []
      hierarchy_graph_keys = {}
      top_level_slugs = Set.new
      with_active_extraction_for(predicate_name, as_of) do |data|
        item = builder.call(data.merge('predicate_name' => predicate_name))
        items << item
        top_level_slugs << item.root_slug
        hierarchy_graph_keys[item.term_label] = item
      end
      associate_parents_and_childrens_for(hierarchy_graph_keys, items, predicate_name)
      top_level_slugs.map { |slug| hierarchy_graph_keys.fetch(slug) }
    end
  end

  def self.associate_parents_and_childrens_for(hierarchy_graph_keys, items, predicate_name)
    items.each do |item|
      begin
        hierarchy_graph_keys.fetch(item.parent_term_label).add_child(item) unless item.parent_slugs.empty?
      rescue KeyError => error
        raise Exceptions::MissingHierarchicalParentError.new(predicate_name, error)
      end
    end
  end
  private_class_method :associate_parents_and_childrens_for

  def self.with_active_extraction_for(predicate_name, as_of)
    filename = filename_for_predicate_name(predicate_name: predicate_name)
    json = JSON.parse(File.read(filename))
    json.fetch('values').each do |data|
      yield(data) if data_is_active?(data, as_of)
    end
  end
  private_class_method :with_active_extraction_for

  def self.data_is_active?(data, as_of)
    activated_on = Date.parse(data.fetch('activated_on'))
    return false unless activated_on < as_of
    deactivated_on_value = data['deactivated_on']
    return true if deactivated_on_value.nil?
    deactivated_on = Date.parse(deactivated_on_value)
    return false unless deactivated_on >= as_of
    true
  end
  private_class_method :data_is_active?

  # @api public
  # @since 0.1.0
  def self.active_label_for_uri(options = {})
    predicate_name = options.fetch(:predicate_name)
    term_uri = options.fetch(:term_uri)
    object = active_items_for(predicate_name: predicate_name).detect { |obj| obj.term_uri == term_uri }
    return object.term_label if object
    term_uri
  end

  # @api public
  # @since 0.1.0
  def self.active_labels_for(options = {})
    predicate_name = options.fetch(:predicate_name)
    active_items_for(predicate_name: predicate_name).map(&:term_label)
  end

  # @api private
  def self.filename_for_predicate_name(options = {})
    predicate_name = options.fetch(:predicate_name)
    filename = File.join(DATA_DIRECTORY, "#{File.basename(predicate_name)}.json")
    return filename if File.exist?(filename)
    raise Locabulary::Exceptions::RuntimeError, "Unable to find predicate_name: #{predicate_name}"
  end

  # @api private
  def self.active_cache
    @active_cache ||= {}
  end

  # @api private
  def self.active_hierarchical_root_caches
    @active_hierarchical_root_caches ||= {}
  end

  # @api private
  def self.reset_active_cache!
    @active_cache = nil
    @active_hierarchical_root_caches = nil
  end
end
