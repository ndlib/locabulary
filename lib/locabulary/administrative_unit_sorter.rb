require 'locabulary/items/base'
require 'hanami/utils/string'
module Locabulary

  class AdministrativeUnitSorter
    #input looks like
    # {"University of Notre Dame"=>
    #  {'University of Notre Dame:Hesburgh Libraries' => 'Hesburgh Libraries',
    #  'University of Notre Dame:Centers and Institutes' => 'Centers and Institutes',
    #  'University of Notre Dame:School of Architecture' => 'School of Architecture',
    #  'University of Notre Dame:College of Arts and Letters' => 'College of Arts and Letters',
    #  'University of Notre Dame:Mendoza College of Business' => 'Mendoza College of Business',
    #  "University of Notre Dame:First Year of Studies" =>"First Year of Studies"}
    # }
    attr_reader :unsorted_facet_tree, :nodes
    def initialize(unsorted_facet_tree = {})
      @unsorted_facet_tree = unsorted_facet_tree
      @nodes = nodes
    end

    def sorted_hierarchical_facets_for
      puts "unsorted_facet_tree: #{unsorted_facet_tree.inspect}"
      nodes = []
      unsorted_facet_tree.each_pair do |key, sub_facets|
        puts "Key: #{key.inspect}, subfacet:#{sub_facets.inspect}"
        nodes << build_node_for(key, sub_facets)
      end
      nodes
    end

    def sort_multi_array(items)
      items = items.sort_by{|item| item.children}
      items.each{ |item| item['children'] = sort_multi_array(item['children']) if (item['children'].nil? ? [] : item['children']).size > 0 }
      items
    end

    def build_node_for(value , sub_facets)
      node = new_node(value)
      unless sub_facets.is_a?(String)
        sub_facets.each_pair do |subvalue, sub_sub_facets|
          node.add_child(build_node_for(subvalue, sub_sub_facets))
        end
        sorted_children = node.children
        puts "####### Sorted Children :->>>>> #{sorted_children.inspect} #######"
      end
      node
    end

    def new_node(value)
      puts "Create newnode for: #{value.inspect}"
      roots = Locabulary.active_hierarchical_roots(predicate_name: 'administrative_units')
      term_label=value.sub(':', '::')
      roots.each do |root|
        root.children.each do |administrative_unit|
          if administrative_unit.term_label.eql?(term_label)
            puts "######### Matching administrative_unit:#{administrative_unit.inspect} #########"
            return administrative_unit
          end
        end
      end
      value
      # An object that has #add_child and #children (which are then sorted)
      # See https://github.com/ndlib/locabulary/blob/ndlib-curatend-347/lib/locabulary/items/base.rb#L88-L97 for ideas
    end
  end

  def default_sorted_hash
    {}
  end
end
require 'locabulary/items/administrative_unit'
