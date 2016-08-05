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
  # @param [Hash] options
  # @option options [String] :predicate_name
  # @option options [Array<#hits, #value>] :faceted_items
  # @option options [String] :faceted_item_hierarchy_delimiter
  # @return Array[<FacetWrapperForItem>]
  #
  # @see Locabulary::Commands::BuildOrderedHierarchicalTree
  def self.build_ordered_hierarchical_tree(options = {})
    Commands::BuildOrderedHierarchicalTreeCommand.call(options)
  end

  # @api public
  # @since 0.1.0
  #
  # Responsible for extracting a non-hierarchical sorted array of Locabulary::Item::Base objects for the given predicate_name.
  #
  # @param [Hash] options
  # @option options [String] :predicate_name
  # @option options [Date] :as_of (Date.today)
  # @return Array[<Locabulary::Item::Base>]
  #
  # @see Locabulary::Commands::ActiveItemsForCommand
  def self.active_items_for(options = {})
    Commands::ActiveItemsForCommand.call(options)
  end

  # @api public
  # @since 0.4.0
  #
  # Responsible for transforming the flat data for the given :predicate_name
  # into a hierarchy.
  #
  # @param [Hash] options
  # @option options [String] :predicate_name
  # @option options [Date] :as_of (Date.today)
  # @return [Array<Locabulary::Item::Base>] - the root nodes
  def self.active_hierarchical_roots(options = {})
    Commands::ActiveHierarchicalRootsCommand.call(options)
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
    Utility.with_extraction_for(predicate_name) do |data|
      next unless data.fetch('term_label') == term_label
      item = Items.build(data.merge('predicate_name' => predicate_name))
      break if data_is_active?(data, as_of)
    end
    return item unless item.nil?
    raise Locabulary::Exceptions::ItemNotFoundError.new(predicate_name, term_label)
  end

  # @api public
  # @since 0.1.0
  #
  # @param [Hash] options
  # @option options [String] :predicate_name
  # @option options [String] :term_uri
  # @option options [String] :as_of (Date.today)
  #
  # @return [String] a label or URI
  #
  # @see Locabulary.active_items_for
  def self.active_label_for_uri(options = {})
    term_uri = options.fetch(:term_uri)
    object = active_items_for(options).detect { |obj| obj.term_uri == term_uri }
    return object.term_label if object
    term_uri
  end

  # @api public
  # @since 0.1.0
  #
  # Return an Array of term labels for the given :predicate_name
  #
  # @param [Hash] options
  # @option options [String] :predicate_name
  # @option options [String] :as_of (Date.today)
  # @return [Array<String>] an array of Locabuarly::Item::Base#term_label
  #
  # @see Locabulary.active_items_for
  def self.active_labels_for(options = {})
    active_items_for(options).map(&:term_label)
  end

  # @api private
  def self.reset_active_cache!
    Commands::ActiveItemsForCommand.reset_cache!
    Commands::ActiveHierarchicalRootsCommand.reset_cache!
  end
end
