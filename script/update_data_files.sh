#!/usr/bin/env ruby -U
if !ENV.key?('BUNDLE_GEMFILE')
  $stderr.puts "You need to call the command via `bundle exec script/#{File.basename(__FILE__)}`"
  $stderr.puts "You will also need to make sure you have valid information in ./config/client_secrets.example.yml."
  abort(1)
end

require 'locabulary/json_creator'

puts "Updating Administrative Units"
json_creator = Locabulary::JsonCreator.new "1oBW5FCTtYXsUi8roBiMRBLFY3dXamhTqy-kiG2rqu5Q", "administrative_units"
json_creator.create_or_update
json_creator.write_to_file
