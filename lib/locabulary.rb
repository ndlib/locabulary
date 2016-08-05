require 'date'
require 'json'
require 'locabulary/exceptions'
require 'locabulary/items'
require 'locabulary/commands/build_ordered_hierarchical_tree_command'
require 'locabulary/commands/active_items_for_command'

# @since 0.1.0
module Locabulary
  DATA_DIRECTORY = File.expand_path("../../data/", __FILE__).freeze

  # @api private
  # @since 0.5.0
  #
  # Responsible for building a hierarchical tree from faceted items, and ordering the nodes as per the presentation sequence for the
  # associated predicate_name.
  #
  # @param options [Hash]
  # @option predicate_name [String]
  # @option faceted_items [Array<#hits, #value>]
  # @option faceted_item_hierarchy_delimiter [String]
  # @return Array[<FacetWrapperForItem>]
  #
  # @see Locabulary::Commands::BuildOrderedHierarchicalTree
  def self.build_ordered_hierarchical_tree(options = {})
    Commands::BuildOrderedHierarchicalTreeCommand.call(options)
  end

  # @api public
  # @since 0.1.0
  #
  # Responsible for extracting a non-hierarchical sorted array of Locabulary::Item for the given predicate_name.
  #
  # @param options [Hash]
  # @option predicate_name [String]
  # @option as_of [Date]
  def self.active_items_for(options = {})
    Commands::ActiveItemsForCommand.call(options)
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

  # @api public
  # @since 0.5.0
  # @param options [Hash]
  # @option predicate_name [String]
  # @option term_label [String]
  # @option as_of [Date] Optional
  # @raise ItemNotFoundError if unable to find label for predicate_name
  # @return Locabulary::Item
  def self.item_for(options = {})
    predicate_name = options.fetch(:predicate_name)
    term_label = options.fetch(:term_label)
    as_of = options.fetch(:as_of) { Date.today }
    item = nil
    with_extraction_for(predicate_name) do |data|
      next unless data.fetch('term_label') == term_label
      item = Items.build(data.merge('predicate_name' => predicate_name))
      break if data_is_active?(data, as_of)
    end
    return item unless item.nil?
    raise Locabulary::Exceptions::ItemNotFoundError.new(predicate_name, term_label)
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

  def self.with_extraction_for(predicate_name)
    Utility.with_extraction_for(*args, &block)
  end
  private_class_method :with_extraction_for

  def self.with_active_extraction_for(*args, &block)
    Utility.with_active_extraction_for(*args, &block)
  end
  private_class_method :with_active_extraction_for

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
  def self.active_hierarchical_root_caches
    @active_hierarchical_root_caches ||= {}
  end

  # @api private
  def self.reset_active_cache!
    Commands::ActiveItemsForCommand.reset_cache!
    @active_hierarchical_root_caches = nil
  end
end
