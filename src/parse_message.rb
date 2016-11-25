require 'pry'
require 'line/bot'
require 'mysql2'

# メッセージを受け取り、返信用メッセージ文字列を返却する
def parse_message(msg, mid)
  ret = ""

  if msg.match(/^私の名前は(.+)です$/) then
	ret = register_name(msg,mid)
  elsif msg.match(/^教えて.*$/) then
	ret = explain_help()
  elsif msg.match(/.+の予定を教えて$/) then
	  ret = tell_schedule(msg,mid)
  else
    ret = "わかりません。使い方を見たい時は「教えて」と言ってください"
  end

  return ret
end

# 名前の登録
def register_name(msg,mid)
  name = msg.gsub(/^私の名前は(.+)です$/, '\1')
  sql = %q{UPDATE user SET name = ? WHERE mid = ?}
  statement = $client.prepare(sql)
  result = statement.execute(name,mid)
  ret = name + "さん。こんにちは。お名前を登録しました。"
  retun ret
end

# ヘルプ
def explain_help()
  ret = "予定を教えてあげるカレンちゃんです"
  return ret
end

# 予定を教えてあげる
def tell_schedule(msg,mid)
  ret = "今週の予定はXXです"
  return ret
end

# test
# $config = YAML.load_file('./config/config.yaml')
# $client = Mysql2::Client.new($config["db"])
# p parse_message("ホゲホゲ", "dummy")
# p parse_message("私の名前はあつしです", "dummy")
# p parse_message("教えてカレン", "dummy")
# p parse_message("教えて", "dummy")
# p parse_message("今日の予定を教えて", "dummy")
