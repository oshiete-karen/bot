require 'pry'
require 'line/bot'
require 'mysql2'

# メッセージを受け取り、返信用メッセージ文字列を返却する
def parse_message(msg, mid)
  if msg.match(/^[教えて|help|ヘルプ].*$/)
    explain_help()
  elsif msg.match(/^私の名前は(.+)です$/)
    register_name($1,mid)
  elsif msg.match(/.+の予定.+$/)
    tell_schedule(msg,mid)
  elsif msg.match(/^登録.+/)
    register_schedule(msg,mid)
  else
    "わかりません。使い方を見たい時は「教えて」と言ってください"
  end
end

# ヘルプ
def explain_help()
  ret = "予定を教えてあげるカレンちゃんです"
  return ret
end

# 名前の登録
def register_name(name, mid)
  sql = %q{UPDATE user SET name = ? WHERE mid = ?}
  statement = $client.prepare(sql)
  result = statement.execute(name,mid)
  "#{name}さん。こんにちは。お名前を登録しました。"
end

# 予定を教えてあげる
def tell_schedule(msg,mid)
  ret = "予定はありません"

  cr = get_credentials_by_mid(mid)
  # TODO: これを使ってgoogleカレンダーにアクセスして予定を取得

  # TODO: パターンを増やしていく
  today = /今日の予定[を教えて|をおしえて|は何？|は？]/
  tomorrow = /明日の予定[を教えて|をおしえて|は何？|は？]/
  day_after_tomorrow = /明後日の予定[を教えて|をおしえて|は何？|は？]/

  if msg.match(today) then
    ret = "今日の予定はXXですよ（というのを実装する予定です）"
  elsif msg.match(tomorrow) then
  ret = "明日の予定はXXですよ（というのを実装する予定です）"
  elsif msg.match(day_after_tomorrow) then
  ret = "明後日の予定はXXですよ（というのを実装する予定です）"
  end

  return ret
end

# 予定を登録する
def register_schedule(msg,mid)

  ret = "予定を登録できませんでした"

  # 分は、余裕があれば
  # 月、日、時、内容 の４要素がこの順に並ぶものを受け付ける（ TODO: パターンを広げていく）
  patterns = [
    /^登録[^0-9]*([0-9]{,2})月[^0-9]*([0-9]{,2})日[^0-9]*([0-9]{,2})時に(.+)$/,
    /^登録[^0-9]*([0-9]{,2})\/([0-9]{,2}) *([0-9]{,2}):00 (.+)$/
  ]

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

# 何もしないやつ
# p parse_message("ホゲホゲ", "dummy")

# 名前の登録さん
# p parse_message("私の名前はあつしです", "dummy")

# ヘルプ
# p parse_message("教えてカレン", "dummy")
# p parse_message("教えて", "dummy")
# p parse_message("help", "dummy")
# p parse_message("help me", "dummy")
# p parse_message("ヘルプ", "dummy")
# p parse_message("ヘルプミー", "dummy")

# 予定問い合わせ
# p parse_message("今日の予定を教えて", "dummy")
# p parse_message("今日の予定をおしえて", "dummy")
# p parse_message("今日の予定は？", "dummy")
# p parse_message("明日の予定を教えて", "dummy")
# p parse_message("明日の予定をおしえて", "dummy")
# p parse_message("明日の予定は？", "dummy")
# p parse_message("明後日の予定を教えて", "dummy")
# p parse_message("明後日の予定をおしえて", "dummy")
# p parse_message("明後日の予定は？", "dummy")

# 予定登録
# p parse_message("登録したい 12月25日15時にクリスマス","dummy")
# p parse_message("登録12月25日15時にクリスマス","dummy")
# p parse_message("登録：12月25日15時にクリスマス","dummy")
# p parse_message("登録ふふうf12月25日15時にクリスマス","dummy")
# p parse_message("登録11112月25日15時にクリスマス","dummy") # できません
# p parse_message("登録 12/25 15:00 クリスマス2","dummy")
