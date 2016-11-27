require "mysql2"
require "./bin/store_user_events"

config = YAML.load_file("./config/config.yaml")
mysql_client = Mysql2::Client.new(config["db"])

sql = %q{SELECT id FROM user}
statement = mysql_client.prepare(sql)
result = statement.execute.to_a

result.each do |obj|
  begin
    user_id = obj["id"]
    events = UserEvents.new(user_id)
    events.store(events.fetch)
  rescue => e
    p e
  end
end
