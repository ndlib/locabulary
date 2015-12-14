require "google/api_client"
require "google_drive"
require 'highline/import'
require 'json'

class JsonCreator

  def initialize(document_key, vocabulary, data_fetcher = default_data_fetcher)
    @document_key = document_key
    @vocabulary = vocabulary
    @output_filepath = "data/#{vocabulary}.json"
    @data_fetcher = data_fetcher
  end

  attr_reader :document_key, :vocabulary, :data_fetcher, :spreadsheet_data, :json_data
  attr_accessor :output_filepath
  ORDER = {
    "University" => 100,
    "College" => 200,
    "Center" => 500,
    "Department" => 300,
    "Institute" => 400
  }

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
      return @secrets if @secrets
      secrets_path = File.join(File.dirname(FILE_PATH), '../config/client_secrets.example.yml')
      secrets_path = File.join(File.dirname(FILE_PATH), '../config/client_secrets.yml') if File.exist? File.join(File.dirname(FILE_PATH), '../config/client_secrets.yml')
      @secrets = YAML.load(File.open(File.join(secrets_path)))
    end
  end

  def get_required_data_from_spreadsheet
    final = {}
    line = []
    spreadsheet_data.shift
    spreadsheet_data.each do |row|
      line << row[0]
      line << row[1] if row[1] && !row[1].empty?
      line << row[2] if row[2] && !row[2].empty?
      final[ line.join('::') ] = row[3]
      line = []
    end
    final
  end

  def convert_to_json(data)
    json_array = []
    data.each do |key, value|
      data_map = {
        "predicate_name" => vocabulary,
        "term_label" => key,
        "term_uri" => nil,
        "default_presentation_sequence" => ORDER[value],
        "activated_on" => "2015-07-22",
        "deactivated_on" => nil
      }
      json_array << data_map
    end
    @json_data = JSON.pretty_generate(json_array)
  end
end