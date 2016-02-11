require_relative '../script/json_creator'
require 'minitest/autorun'

class JsonCreatorTest < MiniTest::Test
  def test_it_converts_a_hash_to_json_file
    array_of_data = [
      ['Column header 1', 'Column header 2', 'Column header 3', 'Column header 4','Column header 5','Column header 6','Column header 7','Column header 8','Column header 9','Column header 10'],
      ['University of Notre Dame', 'School of Architecture', '', 'College', 'http://architecture.nd.edu/','', '', '','', ''	],
      ['University of Notre Dame', 'Centers and Institutes', 'Center for Building Communities', 'CenterOrInstitute', 'http://buildingcommunities.nd.edu/','','', '', 'University of Notre Dame::School of Architecture']
    ]

    data_fetcher = ->(document_key) {
      array_of_data
    }

    expected_output = {
        "predicate_name" => "administrative_units",
        "values" => [
          {
            "predicate_name"=> "administrative_units",
            "term_label"=> "University of Notre Dame::School of Architecture",
            "term_uri"=> "http://architecture.nd.edu/",
            "deposit_label"=> "",
            "description" => "",
            "grouping" => "",
            "affiliation" => "",
            "presentation_sequence"=> 200,
            "activated_on" => "2015-07-22",
            "deactivated_on" => nil
          },
          {
            "predicate_name" => "administrative_units",
            "term_label" => "University of Notre Dame::Centers and Institutes::Center for Building Communities",
            "term_uri" => "http://buildingcommunities.nd.edu/",
            "deposit_label" => "",
            "description" => "",
            "grouping" => "",
            "affiliation" => "University of Notre Dame::School of Architecture",
            "presentation_sequence" => nil,
            "activated_on" => "2015-07-22",
            "deactivated_on" => nil
          }
        ]
    }

    jcreator = JsonCreator.new('dummy', 'administrative_units', data_fetcher)
    jcreator.create_or_update
    assert_equal(jcreator.json_data, JSON.pretty_generate(expected_output))
  end
end
