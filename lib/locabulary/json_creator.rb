require "google/api_client"
require "google_drive"
require 'highline/import'
require 'locabulary'
require 'locabulary/items'
require 'json'

module Locabulary
  # Responsible for capturing predicate_name from a given source and writing it to a file
  class JsonCreator
    def initialize(document_key, predicate_name, data_fetcher = default_data_fetcher)
      @document_key = document_key
      @predicate_name = predicate_name
      @output_filepath = Locabulary.filename_for_predicate_name(predicate_name: predicate_name)
      @data_fetcher = data_fetcher
    end

    attr_reader :document_key, :predicate_name, :data_fetcher, :spreadsheet_data, :json_data
    attr_accessor :output_filepath

    def create_or_update
      rows = data_fetcher.call(document_key)
      data = extract_data_from(rows)
      convert_to_json(data)
    end

    # :nocov:
    def write_to_file
      File.open(output_filepath, "w") do |f|
        f.puts json_data
      end
    end
    # :nocov:

    private

    def extract_data_from(rows)
      spreadsheet_data = []
      header = rows[0]
      rows[1..-1].each do |row|
        # The activated_on is a present hack reflecting a previous value
        row_data = { "predicate_name" => predicate_name, "activated_on" => "2015-07-22", "default_presentation_sequence" => nil }
        row.each_with_index do |cell, index|
          row_data[header[index]] = cell unless cell.to_s.strip == ''
        end
        spreadsheet_data << row_data
      end
      spreadsheet_data
    end

    def default_data_fetcher
      ->(document_key) { GoogleSpreadsheet.new(document_key).all_rows }
    end

    def convert_to_json(data)
      json_array = data.map do |row|
        Locabulary::Items.build(row).to_h
      end
      @json_data = JSON.pretty_generate("predicate_name" => predicate_name, "values" => json_array)
    end

    # :nocov:
    # Responsible for interacting with Google Sheets and retrieiving relevant information
    class GoogleSpreadsheet
      attr_reader :access_token, :document_key, :session

      private :session

      def initialize(document_key)
        @document_key = document_key
        configure_oauth!
        @session = GoogleDrive.login_with_oauth(access_token)
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

      def all_rows
        session.spreadsheet_by_key(document_key).worksheets[0].rows
      end

      def client_secrets
        @secrets ||= YAML.load(File.open(File.join(secrets_path)))
      end

      def secrets_path
        if File.exist? File.join(File.dirname(__FILE__), '../../config/client_secrets.yml')
          File.join(File.dirname(__FILE__), '../../config/client_secrets.yml')
        else
          File.join(File.dirname(__FILE__), '../../config/client_secrets.example.yml')
        end
      end
    end
  end
end
