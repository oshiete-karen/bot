require 'google/apis/calendar_v3'
require 'googleauth'
require 'googleauth/stores/file_token_store'
require 'fileutils'
require "mysql2"
require "./src/mysql_token_store"
require "pry"
config = YAML.load_file("./config/config.yaml")
mysql_client = Mysql2::Client.new(config["db"])
token_store = Google::Auth::Stores::MySQLTokenStore.new(mysql_client)
user_id = ARGV[0]
_credentials = token_store.load(user_id)
APPLICATION_NAME = 'Google Calendar API Ruby Quickstart'
CLIENT_SECRETS_PATH = './config/client_secrets.json'
CREDENTIALS_PATH = File.join(Dir.home, '.credentials',
                             "calendar-ruby-quickstart.yaml")

service = Google::Apis::CalendarV3::CalendarService.new
service.client_options.application_name = APPLICATION_NAME
client_id = Google::Auth::ClientId.from_file(CLIENT_SECRETS_PATH)
credentials = Google::Auth::UserRefreshCredentials.new
credentials.client_id = _credentials["client_id"]
credentials.client_secret = client_id.secret
credentials.access_token = _credentials["access_token"]
credentials.refresh_token = _credentials["refresh_token"]
credentials.scope = _credentials["scope"]
service.authorization = credentials

# Fetch the next 10 events for the user
calendar_id = 'primary'
response = service.list_events(calendar_id,
                               max_results: 100,
                               single_events: true,
                               order_by: 'startTime',
                               time_min: Time.now.iso8601)

response.items.each do |event|
  # あとでbulk insertのやり方を調べる
  # values = response.items.map { |event| "(#{event.id}, user_id, #{event.summary}, #{event.start}, #{event.end})" }.join(",")
  sql = "INSERT IGNORE INTO events (`id`, `user_id`, `summary`, `start`, `end`) VALUES (?, ?, ?, ?, ?);"
  statement = mysql_client.prepare(sql)
  p event.id
  result = statement.execute(event.id, user_id, event.summary, event.start.date_time, event.end.date_time)
end
