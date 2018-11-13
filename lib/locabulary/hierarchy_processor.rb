# :nodoc:
module Locabulary
  # @api private
  #
  # Responsible for processing an flat enumeration of data and creating
  # a sorted hierarchy.
  #
  # @note This is an extraction of common logic found in two separate classes.
  class HierarchyProcessor
    def self.call(options = {})
      new(options).call
    end

    private_class_method :new

    # @param options [Hash]
    # @option options [#call] :item_builder - when called will create a Locabulary::Items::Base object
    # @option options [#call] :predicate_name -
    # @option options [#call] :enumerator - when called will yield an enumerated_object to the item_builder
    def initialize(options = {})
      @item_builder = options.fetch(:item_builder)
      @predicate_name = options.fetch(:predicate_name)
      @enumerator = options.fetch(:enumerator)
    end

    def call
      items = []
      hierarchy_graph_keys = {}
      top_level_slugs = Set.new
      enumerator.call do |enumerated_object|
        item = item_builder.call(enumerated_object)
        items << item
        top_level_slugs << item.root_slug
        hierarchy_graph_keys[item.term_label] = item
      end
      associate_parents_and_childrens_for(hierarchy_graph_keys, items)
      top_level_slugs.map { |slug| hierarchy_graph_keys.fetch(slug) }.sort
    end

    private

    attr_reader :item_builder, :predicate_name, :enumerator

    def associate_parents_and_childrens_for(hierarchy_graph_keys, items)
      items.each do |item|
        begin
          hierarchy_graph_keys.fetch(item.parent_term_label).add_child(item) unless item.parent_slugs.empty?
        rescue KeyError => error
          raise Exceptions::MissingHierarchicalParentError.new(predicate_name, error, item)
        end
      end
    end
  end
  private_constant :HierarchyProcessor
end
