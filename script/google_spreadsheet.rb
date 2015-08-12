require "google/api_client"
require "google_drive"
require 'highline/import'
require 'jbuilder'
require 'json'

class GoogleSpreadsheet

  def initialize(document_key:, output_filepath:)
    @document_key = document_key
    @output_filepath = output_filepath
    @access_token = ""
  end

  attr_reader :client, :document_key, :output_filepath, :access_token, :spreadsheet_data
  ORDER = {"University" => 100, "College" => 200, "Center" => 500, "Department" => 300, "Institute" => 400}
  FILE_PATH = __FILE__

  def create_json!
    configure_oauth!
    read_spreadsheet
    write_to_file(get_required_data_from_spreadsheet)
  end

  private

  def configure_oauth!
    @client = Google::APIClient.new
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

    @spreadsheet_data = []

    (1..ws.num_rows).each do |row|
      row_data = []
      (1..ws.num_cols).each do |col|
        row_data << ws[row, col]
      end
      @spreadsheet_data << row_data
    end
  end

  def get_required_data_from_spreadsheet
    final = {}
    line = []
    spreadsheet_data.shift
    spreadsheet_data.each_with_index do |row, index|
      line << row[0]
      line << row[1] if !row[1].empty?
      line << row[2] if !row[2].empty?
      final[ line.join('::') ] = row[3]
      line = []
    end
    final
  end

  def convert_to_json(data)
    json_array = []
    data.each do |key, value|
      json_string = Jbuilder.encode do |json|
        json.set!("predicate_name", "administrative_units")
        json.set!("term_label", key)
        json.set!("term_uri", nil)
        json.set!("default_presentation_sequence", ORDER[value])
        json.set!("activated_on", "2015-07-22")
        json.set!("deactivated_on", nil)
      end
      json_array << JSON.parse(json_string)
    end
    json_array
  end

  def write_to_file(data)
    f = File.new(output_filepath, "w")
    f.puts JSON.pretty_generate(convert_to_json(data))
    f.flush
    f.close
  end

  def client_secrets
    return @secrets if @secrets
    secrets_path = File.join(File.dirname(FILE_PATH), '../config/client_secrets.example.yml')
    secrets_path = File.join(File.dirname(FILE_PATH), '../config/client_secrets.yml') if File.exist? File.join(File.dirname(FILE_PATH), '../config/client_secrets.yml')
    @secrets = YAML.load(File.open(File.join(secrets_path)))
  end

end
spread_sheet = GoogleSpreadsheet.new(document_key: ARGV[0], output_filepath: ARGV[1])
spread_sheet.create_json!
