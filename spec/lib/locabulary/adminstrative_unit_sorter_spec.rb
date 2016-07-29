require 'spec_helper'
require 'locabulary/administrative_unit_sorter'

RSpec.describe Locabulary::AdministrativeUnitSorter do
  let(:mock_input_hash) do
    {"University of Notre Dame"=>
      { :_=>OpenStruct.new(  qvalue: "University of Notre Dame", value: "University of Notre Dame", hits: 3),
        "College of Engineering"=>{
          :_=>OpenStruct.new(  qvalue: "University of Notre Dame:College of Engineering", value: "College of Engineering", hits: 1),
          "Electrical Engineering"=> {
            :_=>OpenStruct.new(  qvalue: "University of Notre Dame:College of Engineering:Electrical Engineering", value: "Electrical Engineering", hits: 1)}},
        "College of Arts and Letters"=>
          { :_=>OpenStruct.new(  qvalue: "University of Notre Dame:College of Arts and Letters", value: "College of Arts and Letters", hits: 2),
            "Africana Studies"=>
              { :_=>OpenStruct.new(  qvalue: "University of Notre Dame:College of Arts and Letters:Africana Studies", value: "Africana Studies", hits: 1)},
            "East Asian Languages & Cultures"=>
              { :_=>OpenStruct.new(  qvalue: "University of Notre Dame:College of Arts and Letters:East Asian Languages & Cultures", value: "East Asian Languages & Cultures", hits: 1)}},
        "Mendoza College of Business"=>{
          :_=>OpenStruct.new(  qvalue: "University of Notre Dame:Mendoza College of Business", value: "Mendoza College of Business", hits: 1),
          "Finance"=> {
            :_=>OpenStruct.new(  qvalue: "University of Notre Dame:Mendoza College of Business:Finance", value: "Finance", hits: 1)
          }
        }
      }
    }
  end

  let(:expected_output) do
    {"University of Notre Dame"=>
      { :_=>OpenStruct.new(  qvalue: "University of Notre Dame", value: "University of Notre Dame", hits: 3),
        "College of Arts and Letters"=>
          { :_=>OpenStruct.new(  qvalue: "University of Notre Dame:College of Arts and Letters", value: "College of Arts and Letters", hits: 2),
            "Africana Studies"=>
                { :_=>OpenStruct.new(  qvalue: "University of Notre Dame:College of Arts and Letters:Africana Studies", value: "Africana Studies", hits: 1)},
            "East Asian Languages & Cultures"=>
                { :_=>OpenStruct.new(  qvalue: "University of Notre Dame:College of Arts and Letters:East Asian Languages & Cultures", value: "East Asian Languages & Cultures", hits: 1)}
        },
        "Mendoza College of Business"=>{
          :_=>OpenStruct.new(  qvalue: "University of Notre Dame:Mendoza College of Business", value: "Mendoza College of Business", hits: 1),
          "Finance"=> {
          :_=>OpenStruct.new(  qvalue: "University of Notre Dame:Mendoza College of Business:Finance", value: "Finance", hits: 1)
          }
        },
        "College of Engineering"=>{
          :_=>OpenStruct.new(  qvalue: "University of Notre Dame:College of Engineering", value: "College of Engineering", hits: 1),
          "Electrical Engineering"=> {
          :_=>OpenStruct.new(  qvalue: "University of Notre Dame:College of Engineering:Electrical Engineering", value: "Electrical Engineering", hits: 1)}},
      }
    }
  end
end
