require 'pry'
require 'line/bot'
require 'mysql2'

# メッセージを受け取り、返信用メッセージ文字列を返却する
def parse_message(msg, mid)
  ret = ""

  if msg.match(/^教えて.*$/) then
    ret = explain_help()
  elsif msg.match(/^私の名前は(.+)です$/) then
	ret = register_name(msg,mid)
  elsif msg.match(/.+の予定を教えて$/) then
	ret = tell_schedule(msg,mid)
  elsif msg.match(/登録/) then
	ret = register_schedule(msg,mid)
  else
    ret = "わかりません。使い方を見たい時は「教えて」と言ってください"
  end

  return ret
end

# ヘルプ
def explain_help()
  ret = "予定を教えてあげるカレンちゃんです"
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

# 予定を教えてあげる
def tell_schedule(msg,mid)
  ret = "今週の予定はXXです"
  return ret
end

# 予定を登録する
def register_schedule(msg,mid)

  ret = "予定を登録できませんでした"

  # 分は、余裕があれば
  # 月、日、時、内容 の４要素がこの順に並ぶものを受け付ける（ TODO: ここは余裕があれば柔軟に広げていく）
  patterns = [
    /^登録[^0-9]*([0-9]{,2})月[^0-9]*([0-9]{,2})日[^0-9]*([0-9]{,2})時に(.+)$/,
    /^登録[^0-9]*([0-9]{,2})\/([0-9]{,2}) *([0-9]{,2}):00 (.+)$/
  ]
  # pattern = /^登録[^0-9]*([0-9]{,2})月[^0-9]*([0-9]{,2})日[^0-9]*([0-9]{,2})時に(.+)$/

  patterns.each { |pattern|
    if msg.match(pattern) then
      # TODO: 登録をする
      ret = $1 + "月" + $2 + "日" + $3 + "時 " + $4 + " という予定を登録しました（というのを実装する予定です）"
	  break
    end
  }

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

# p parse_message("登録したい 12月25日15時にクリスマス","dummy")
# p parse_message("登録12月25日15時にクリスマス","dummy")
# p parse_message("登録：12月25日15時にクリスマス","dummy")
# p parse_message("登録ふふうf12月25日15時にクリスマス","dummy")
# p parse_message("登録11112月25日15時にクリスマス","dummy")
# p parse_message("登録 12/25 15:00 クリスマス2","dummy")
