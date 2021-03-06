require 'locabulary/services'

# @since 0.1.0
# @api public
#
# Locabulary is structured to expose public interface methods in the base module (e.g. `Locabulary`).
# Other things to consider are the Locabulary::Items::Base object as it defines the returned data structure
# for the public Locabulary methods.
#
# @see Locabury::Items::Base
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
  # @see Locabulary::Services
  def self.build_ordered_hierarchical_tree(options = {})
    Services.call(:build_ordered_hierarchical_tree, options)
  end

  # @api public
  # @since 0.1.0
  #
  # Responsible for extracting a non-hierarchical sorted array of active Locabulary::Items::Base objects for the given predicate_name.
  #
  # @param [Hash] options
  # @option options [String] :predicate_name
  # @option options [Date] :as_of (Date.today)
  # @return [Array<Locabulary::Items::Base>]
  #
  # @see Locabulary::Services
  def self.active_items_for(options = {})
    Services.call(:active_items_for, options)
  end

  # @api public
  # @since 0.7.0
  #
  # Responsible for extracting a non-hierarchical sorted array of Locabulary::Items::Base objects for the given predicate_name.
  #
  # @param [Hash] options
  # @option options [String] :predicate_name
  # @return [Array<Locabulary::Items::Base>]
  #
  # @see Locabulary::Services
  def self.all_items_for(options = {})
    Services.call(:all_items_for, options)
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
  #
  # @see Locabulary::Services
  def self.active_hierarchical_roots(options = {})
    Services.call(:active_hierarchical_roots, options)
  end

  # @api public
  #
  # Responsible for transforming the flat data for the given :predicate_name
  # an array for use in creating a menu.
  #
  # @param [Hash] options
  # @option options [String] :predicate_name
  # @option options [Date] :as_of (Date.today)
  # @return [Array<Hash] - [{ category_title: String, item: Locabulary::Items::Base>}]
  #
  # @see Locabulary::Services
  def self.hierarchical_menu_options(options = {})
    Services.call(:hierarchical_menu_options, options)
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
  #
  # @see Locabulary::Services
  def self.item_for(options = {})
    Services.call(:item_for, options)
  end

  # @api public
  # @since 0.1.0
  #
  # For the given :predicate_name and :term_uri return a best fitting human readable label.
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

  # @api public
  # @since 1.0.0
  #
  # Return an Array of term labels for the given :predicate_name
  #
  # @param [Hash] options
  # @option options [String] :predicate_name
  # @return [Array<String>] an array of Locabuarly::Items::Base#term_label
  #
  # @see Locabulary.active_items_for
  def self.all_labels_for(options = {})
    all_items_for(options).map(&:term_label)
  end
end
