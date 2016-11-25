require 'pry'
require 'line/bot'
require 'mysql2'

# メッセージを受け取り、返信用メッセージ文字列を返却する
def parse_message(msg, mid)
  ret = ""

  if msg.match(/^私の名前は(.+)です$/) then
	name = msg.gsub(/^私の名前は(.+)です$/, '\1')
	sql = %q{UPDATE user SET name = ? WHERE mid = ?}
	statement = $client.prepare(sql)
	result = statement.execute(name,mid)
	p result
	ret = name + "さん。始めまして。お名前を登録しました。"

  elsif msg.match(/^教えて.*$/) then
	#   help 的なやつを返す
	ret = "教えてあげる"
  else
    ret = "わかりません。使い方を見たい時は「教えて」と言ってください"
  end

  return ret
end

# test
# $config = YAML.load_file('./config/config.yaml')
# $client = Mysql2::Client.new($config["db"])
# p parse_message("ホゲホゲ", "dummy")
# p parse_message("私の名前はあつしです", "dummy")
# p parse_message("教えてカレン", "dummy")
# p parse_message("教えて", "dummy")
