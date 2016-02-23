require 'spec_helper'
require 'locabulary/json_creator'

RSpec.describe Locabulary::JsonCreator do
  let(:data_fetcher) { ->(_) { array_of_data } }
  let(:array_of_data) do
    [
      [
        'Column header 1', 'Column header 2', 'Column header 3', 'Column header 4', 'Column header 5', 'Column header 6',
        'Column header 7', 'Column header 8', 'Column header 9', 'Column header 10'
      ], [
        'University of Notre Dame', 'School of Architecture', '', 'College', 'http://architecture.nd.edu/', '', '', '', '', ''
      ], [
        'University of Notre Dame', 'Centers and Institutes', 'Center for Building Communities', 'CenterOrInstitute',
        'http://buildingcommunities.nd.edu/', '', '', '', 'University of Notre Dame::School of Architecture'

      ]
    ]
  end
  subject { described_class.new('dummy', 'administrative_units', data_fetcher) }
  its(:default_data_fetcher) { should respond_to(:call) }

  it 'will have an output filename' do
    expect(File.exist?(subject.output_filepath)).to eq(true)
  end
  it 'will convert a hash to a json file' do
    expected_output = {
      "predicate_name" => "administrative_units",
      "values" => [
        {
          "predicate_name" => "administrative_units",
          "term_label" => "University of Notre Dame::School of Architecture",
          "term_uri" => "http://architecture.nd.edu/",
          "deposit_label" => "",
          "description" => "",
          "grouping" => "",
          "affiliation" => "",
          "default_presentation_sequence" => nil,
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
          "default_presentation_sequence" => nil,
          "activated_on" => "2015-07-22",
          "deactivated_on" => nil
        }
      ]
    }

    subject.create_or_update
    expect(subject.json_data).to eq(JSON.pretty_generate(expected_output))
  end
end
