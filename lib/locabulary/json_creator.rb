require "google/api_client"
require "google_drive"
require 'highline/import'
require 'locabulary'
require 'json'

module Locabulary
  # Responsible for capturing vocabulary from a given source and writing it to a file
  class JsonCreator

    ATTRIBUTE_NAMES = [:term_label, :term_uri, :deposit_label, :description, :grouping, :affiliation, :default_presentation_sequence, :activated_on, :deactivated_on].freeze

    attr_reader(*ATTRIBUTE_NAMES)

    def initialize(document_key, vocabulary, data_fetcher = default_data_fetcher)
      @document_key = document_key
      @vocabulary = vocabulary
      @output_filepath = File.join(Locabulary::DATA_DIRECTORY, "#{vocabulary}.json")
      @data_fetcher = data_fetcher
    end

    attr_reader :document_key, :vocabulary, :data_fetcher, :spreadsheet_data, :json_data
    attr_accessor :output_filepath

    def create_or_update
      @spreadsheet_data = data_fetcher.call(document_key)
      convert_to_json(get_required_data_from_spreadsheet)
    end

    def write_to_file
      File.open(output_filepath, "w") do |f|
        f.puts json_data
      end
    end

    private

    attr_writer(*ATTRIBUTE_NAMES)

    def default_data_fetcher
      ->(document_key) { GoogleSpreadsheet.new(document_key).read_spreadsheet }
    end

    class GoogleSpreadsheet
      attr_reader :access_token, :document_key
      FILE_PATH = __FILE__

      def initialize(document_key)
        @document_key = document_key
        configure_oauth!
      end

      def configure_oauth!
        client = Google::APIClient.new
        auth = client.authorization
        auth.client_id = client_secrets.fetch('client_id')
        auth.client_secret = client_secrets.fetch('client_secret')
        auth.scope = ["https://www.googleapis.com/auth/drive.readonly"]
        auth.redirect_uri = "urn:ietf:wg:oauth:2.0:oob"
        puts "\n Open the following URL, login with your credentials and get the authorization code \n\n #{auth.authorization_uri}\n\n"
        auth.code = ask('Authorization Code: ')
        auth.fetch_access_token!
        @access_token = auth.access_token
      end

      def read_spreadsheet
        session = GoogleDrive.login_with_oauth(access_token)
        ws = session.spreadsheet_by_key(document_key).worksheets[0]
        spreadsheet_data = []
        (1..ws.num_rows).each do |row|
          row_data = []
          (1..ws.num_cols).each do |col|
            row_data << ws[row, col]
          end
          spreadsheet_data << row_data
        end
        spreadsheet_data
      end

      def client_secrets
        @secrets ||= YAML.load(File.open(File.join(secrets_path)))
      end

      def secrets_path
        if File.exist? File.join(File.dirname(__FILE__), '../config/client_secrets.yml')
          File.join(File.dirname(__FILE__), '../config/client_secrets.yml')
        else
          File.join(File.dirname(__FILE__), '../config/client_secrets.example.yml')
        end
      end
    end

    def get_required_data_from_spreadsheet
      formatted_data =[]
      line = []
      spreadsheet_data.shift
      spreadsheet_data.each do |row|
        final = {}
        line << row[0]
        line << row[1] if row[1] && !row[1].empty?
        line << row[2] if row[2] && !row[2].empty?
        final[ "term_label" ] = line.join('::')
        final[ "default_presentation_sequence" ] = row[9].to_s.strip == '' ? nil : row[9].to_i
        final[ "term_uri" ] = row[4]
        final[ "deposit_label" ] = row[5]
        final[ "description" ] = row[6]
        final[ "grouping" ] = row[7]
        final[ "affiliation" ] = row[8]
        final[ "activated_on" ] = "2015-07-22"
        final[ "deactivated_on" ] = nil
        formatted_data << final
        line = []
      end
      formatted_data
    end

    def convert_to_json(data)
      json_array = []
      data.each do |row|
        data_map = {"predicate_name"=>vocabulary}
        ATTRIBUTE_NAMES.each do |key|
          data_map[ key ]  = row.fetch(key) { row.fetch(key.to_s, nil) }
        end
        json_array << data_map
      end
      @json_data = JSON.pretty_generate({"predicate_name"=>vocabulary, "values"=> json_array})
    end
  end
end
