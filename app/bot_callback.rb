require 'sinatra/base'
require 'pry'
require 'line/bot'
require 'mysql2'
require './app/user_events'

class BotCallback < Sinatra::Base
  def client
    @client ||= Line::Bot::Client.new { |config|
      config.channel_secret = $config['channel']['channel_secret']
      config.channel_token = $config['channel']['channel_token']
    }
  end

  before '/api/bot_callback' do
    body = request.body.read
    events = client.parse_events_from(body)
    mid = events.first['source']['userId']
    register_id(mid) unless exist?(mid)
    request_authentication(mid, events) unless has_authenticated?(mid)
    #対象となるカレンダーを登録させたいが、とりあえずその人の一番最初に見つかるカレンダーを対象とする
    #register_calendar unless has_calendar_be_registered?(mid)
    fetch_and_store_initial_events(mid) unless any_events?(mid)
  end

  def exist?(mid)
    sql = %q{SELECT mid from user WHERE mid = ?}
    statement = $client.prepare(sql)
    result = statement.execute(mid)

    !result.first.nil?
  end

  def any_events?(mid)
    sql = %q{SELECT user_id FROM events WHERE user_id = ?}
    statement = $client.prepare(sql)
    result = statement.execute(mid_to_user_id(mid))

    !result.first.nil?
  end

  def has_authenticated?(mid)
    sql = %q{SELECT user_id FROM credential WHERE user_id = ?}
    statement = $client.prepare(sql)
    result = statement.execute(mid_to_user_id(mid))

    !result.first.nil?
  end

  def register_id(mid)
    sql = %q{INSERT INTO user (mid) VALUES (?)}
    statement = $client.prepare(sql)
    result = statement.execute(mid)
  end

  def request_authentication(mid, events)
    # TODO template messageにする
    # https://devdocs.line.me/ja/#imagemap-message#template-message
    message = {
        type: 'text',
        text: "https://oshietekaren.info/api/auth/#{mid_to_user_id(mid)}"
    }
    client.reply_message(events.first['replyToken'], message)
  end

  def mid_to_user_id(mid)
    sql = %q{SELECT id FROM user WHERE mid = ?}
    statement = $client.prepare(sql)
    result = statement.execute(mid)

    result.first['id']
  end

  def fetch_and_store_initial_events(mid)
    events = UserEvents.new(mid_to_user_id(mid))
    events.store(events.fetch)
  end

  post '/api/bot_callback' do
    body = request.body.read
    signature = request.env['HTTP_X_LINE_SIGNATURE']
    unless client.validate_signature(body, signature)
      error 400 do 'Bad Request' end
    end

    events = client.parse_events_from(body)
    events.each { |event|
      case event
      when Line::Bot::Event::Follow
        message = {
            type: 'text',
            text: '友達に追加されました（botより）'
        }
        client.reply_message(event['replyToken'], message)

      when Line::Bot::Event::Unfollow
        # DBから該当MIDを削除
        sql = %q{DELETE FROM user WHERE mid = ?}
        statement = $client.prepare(sql)
        result = statement.execute(event['source']['userId'])
        p 'deleted user'

      when Line::Bot::Event::Message
        case event.type
        when Line::Bot::Event::MessageType::Text

          message = {
            type: 'text',
            text: parse_message(event.message['text'], event['source']['userId'])
          }
          client.reply_message(event['replyToken'], message)
        when Line::Bot::Event::MessageType::Image, Line::Bot::Event::MessageType::Video
          message = {
            type: 'text',
            text: '画像とかは、あかんよ'
          }
          client.reply_message(event['replyToken'], message)
        end
      end
    }
    'ok'
  end

# こんな感じでpush届きます
  # post '/api/push_message' do
  #   sql = %q{SELECT mid FROM user WHERE name = ?}
  #   statement = $client.prepare(sql)
  #   result = statement.execute('かどたに')
  #   mid = result.first['mid']
  #   message = {
  #     type: 'text',
  #     text: 'pushです'
  #   }
  #   client.push_message(mid, message)
  #   'OK'
  # end

end
