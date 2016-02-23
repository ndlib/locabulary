#!/usr/bin/env ruby -U
require 'locabulary/json_creator'

puts "Updating Administrative Units"
json_creator = JsonCreator.new "1oBW5FCTtYXsUi8roBiMRBLFY3dXamhTqy-kiG2rqu5Q", "administrative_units"
json_creator.create_or_update
json_creator.write_to_file
