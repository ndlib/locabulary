require 'spec_helper'
require 'locabulary/json_creator'

RSpec.describe Locabulary::JsonCreator do
  let(:data_fetcher) { ->(_) { rows } }
  let(:rows) do
    [
      [
        "term_label", "default_presentation_sequence", "classification", "homepage", "description", "grouping", "affiliation"
      ], [
        "University of Notre Dame", "", "University", "http://www.nd.edu/", "", "", ""
      ], [
        "University of Notre Dame::School of Architecture", "", "College", "http://architecture.nd.edu/", "", "", ""
      ], [
        "University of Notre Dame::College of Arts and Letters", "", "College", "http://al.nd.edu/", "", "The Humanities", ""
      ], [
        "University of Notre Dame::College of Arts and Letters::Non-Departmental", "1", "Department", "", "", "", "University of Notre Dame::School of Architecture"
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
      "predicate_name": "administrative_units",
      "values": [
        {
          "predicate_name": "administrative_units",
          "term_label": "University of Notre Dame",
          "classification": "University",
          "homepage": "http://www.nd.edu/",
          "activated_on": "2015-07-22"
        }, {
          "predicate_name": "administrative_units",
          "term_label": "University of Notre Dame::School of Architecture",
          "classification": "College",
          "homepage": "http://architecture.nd.edu/",
          "activated_on": "2015-07-22"
        }, {
          "predicate_name": "administrative_units",
          "term_label": "University of Notre Dame::College of Arts and Letters",
          "grouping": "The Humanities",
          "classification": "College",
          "homepage": "http://al.nd.edu/",
          "activated_on": "2015-07-22"
        }, {
          "predicate_name": "administrative_units",
          "term_label": "University of Notre Dame::College of Arts and Letters::Non-Departmental",
          "classification": "Department",
          "affiliation": "University of Notre Dame::School of Architecture",
          "default_presentation_sequence": 1,
          "activated_on": "2015-07-22"
        }
      ]
    }

    subject.create_or_update
    expect(subject.json_data).to eq(JSON.pretty_generate(expected_output))
  end
end
