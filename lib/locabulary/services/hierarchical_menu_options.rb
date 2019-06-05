require 'date'
require 'locabulary/item'

module Locabulary
  # :nodoc:
  module Services
    # @api private
    # Responsible for transforming the flat data for the given :predicate_name
    # into a hierarchy.
    class HierarchicalMenuOptionsService
      def self.cache
        @cache ||= {}
      end
      private_class_method :cache

      # @api private
      def self.reset_cache!
        @cache = {}
      end

      # @api private
      # @param options [Array<Locabulary::Items] :roots (ActiveHierarchicalRoots from ActiveHierarchicalRootsService
      # @return [Array<Hash] - Formatted hashes for admin unit selection menu
      def self.call(options = {})
        roots = options.fetch(:roots)
        cache[roots] ||= new(options).call
      end

      private_class_method :new

      def initialize(options = {})
        @roots = options.fetch(:roots)
      end

      def call
        make_items_list_for(roots)
      end

      private

      def make_items_list_for(roots)
        @items_list = []
        roots.each do |admin_unit|
          add_items_to_list_for(item: admin_unit)
        end
        @items_list
      end

      def add_items_to_list_for(item:)
        item.children.each do |admin_unit|
          if admin_unit.selectable?
            add_list_item(parent: item, item: admin_unit)
          else
            add_children_to_list_for(item: admin_unit)
          end
        end
      end

      def add_list_item(parent:, item:)
        # University of Notre Dame is a three-level hierarchy. We only show two levels in the menu
        parent = item if parent.term_label == "University of Notre Dame"
        category_title = parent.selectable_label
        # if this is a new heading, add it to the array
        if (@items_list.find { |f| f[:category_title] == category_title }).nil?
          @items_list << { category_title: category_title }
        end
        # now add the item to the array
        @items_list << { category_title: category_title, item: item }
      end

      def add_children_to_list_for(item:)
        add_items_to_list_for(item: item)
      end

      attr_reader :roots
    end
    private_constant :HierarchicalMenuOptionsService
  end
end
