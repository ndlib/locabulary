GEM_ROOT = File.expand_path('../../', __FILE__)
$LOAD_PATH.unshift File.join(GEM_ROOT, 'lib')
require 'json'
require 'locabulary'

Dir.glob(File.join(GEM_ROOT, 'data/*.json')).each do |filename|
  predicate_name = File.basename(filename, '.json')
  next if predicate_name == 'administrative_units'

  sorted_values = []
  Locabulary.all_items_for(predicate_name: predicate_name).each do |sorted_item|
    hash = sorted_item.to_h
    hash.delete('predicate_name')
    sorted_values << hash
  end

  json_doc = JSON.pretty_generate(
    {
      "predicate_name" => predicate_name,
      "values" => sorted_values
    }
  )

  File.open(filename, 'w+') { |file| file.puts(json_doc) }
end
