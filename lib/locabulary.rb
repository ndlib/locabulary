require 'date'
require 'json'
require 'locabulary/exceptions'
require 'locabulary/item'
require 'locabulary/commands/build_ordered_hierarchical_tree_command'
require 'locabulary/commands/active_items_for_command'
require 'locabulary/commands/active_hierarchical_roots_command'

# @since 0.1.0
module Locabulary
  # @api public
  # @since 0.5.0
  #
  # Responsible for building a hierarchical tree from faceted items, and ordering the nodes as per the presentation sequence for the
  # associated predicate_name.
  #
  # @param [Hash] options
  # @option options [String] :predicate_name
  # @option options [Array<#hits, #value>] :faceted_items
  # @option options [String] :faceted_item_hierarchy_delimiter
  # @return [Array<FacetWrapperForItem>]
  #
  # @see Locabulary::Commands::BuildOrderedHierarchicalTree
  def self.build_ordered_hierarchical_tree(options = {})
    Commands::BuildOrderedHierarchicalTreeCommand.call(options)
  end

  # @api public
  # @since 0.1.0
  #
  # Responsible for extracting a non-hierarchical sorted array of Locabulary::Items::Base objects for the given predicate_name.
  #
  # @param [Hash] options
  # @option options [String] :predicate_name
  # @option options [Date] :as_of (Date.today)
  # @return [Array<Locabulary::Items::Base>]
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
  # @return [Array<Locabulary::Items::Base>] - the root nodes
  def self.active_hierarchical_roots(options = {})
    Commands::ActiveHierarchicalRootsCommand.call(options)
  end

  # @api public
  # @since 0.5.0
  #
  # For the given :predicate_name and :term_label find an item.
  # We prefer to find an active item, but will settle for a non-active item.
  #
  # @param options [Hash]
  # @option options [String] :predicate_name
  # @option options [String] :term_label
  # @option options [Date] :as_of (Date.today)
  # @raise [Locabulary::Exceptions::ItemNotFoundError] if unable to find label for predicate_name
  # @return [Locabulary::Items::Base]
  def self.item_for(options = {})
    predicate_name = options.fetch(:predicate_name)
    term_label = options.fetch(:term_label)
    as_of = options.fetch(:as_of) { Date.today }
    item = nil
    Utility.with_extraction_for(predicate_name) do |data|
      next unless data.fetch('term_label') == term_label
      item = Item.build(data.merge('predicate_name' => predicate_name))
      break if Utility.data_is_active?(data, as_of)
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
  # @return [Array<String>] an array of Locabuarly::Items::Base#term_label
  #
  # @see Locabulary.active_items_for
  def self.active_labels_for(options = {})
    active_items_for(options).map(&:term_label)
  end
end
