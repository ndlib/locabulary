require_relative '../script/json_creator'
require 'minitest/autorun'

class JsonCreatorTest < MiniTest::Test
  def test_it_converts_a_hash_to_json_file
    array_of_data = [
      ['Column header 1', 'Column header 2', 'Column header 3', 'Column header 4'],
      ['University of Notre Dame', 'School of Architecture', '', 'College'],
      ['University of Notre Dame', 'School of Architecture', 'Center for Building Communities', 'Center']
    ]

    data_fetcher = ->(document_key) {
      array_of_data
    }

    expected_output = [
      {
        "predicate_name" => "administrative_units",
        "term_label" => "University of Notre Dame::School of Architecture",
        "term_uri" => nil,
        "default_presentation_sequence" => 200,
        "activated_on" => "2015-07-22",
        "deactivated_on" => nil
      },
      {
        "predicate_name" => "administrative_units",
        "term_label" => "University of Notre Dame::School of Architecture::Center for Building Communities",
        "term_uri" => nil,
        "default_presentation_sequence" => 500,
        "activated_on" => "2015-07-22",
        "deactivated_on" => nil
      }
    ]

    jcreator = JsonCreator.new('dummy', 'administrative_units', data_fetcher)
    jcreator.create_or_update

    assert_equal(jcreator.json_data, JSON.pretty_generate(expected_output))
  end
end
