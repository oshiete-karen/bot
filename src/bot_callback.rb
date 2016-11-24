require 'sinatra/base'
require 'pry'
require 'line/bot'


class BotCallback < Sinatra::Base

  def client
    @client ||= Line::Bot::Client.new { |config|

      config.channel_secret = "ee76c0d1cfc09bd3b338c284f11ab81c"
      config.channel_token = "yla2nurLR9n6mWc2QzHkM5BlcFJkSM34RQFNG2DW9oYNeO8imbiS7eN/AjxCoSa51gNqWNxEaP1h6B/P/ABEpEVuOENAC4qTLPQL38SLzS8Yis6m3gCtigEWeQSz3NBFKHR1qxHy2NWLfc8z90l5xgdB04t89/1O/w1cDnyilFU="

      #config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
      #config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
    }
  end

  post '/api/bot_callback' do
    # これを入れるとブレークポイントになってデバッグできます。require 'pry'が必要です。
    # binding.pry

    body = request.body.read
    signature = request.env['HTTP_X_LINE_SIGNATURE']
    unless client.validate_signature(body, signature)
        error 400 do 'Bad Request' end
    end

    events = client.parse_events_from(body)
    events.each { |event|
        case event
        when Line::Bot::Event::Message
        case event.type
            when Line::Bot::Event::MessageType::Text
                message = {
                    type: 'text',
                    text: event.message['text']
                }
                client.reply_message(event['replyToken'], message)
            when Line::Bot::Event::MessageType::Image, Line::Bot::Event::MessageType::Video
                response = client.get_message_content(event.message['id'])
                tf = Tempfile.open("content")
                tf.write(response.body)
            end
        end
    }

    "ok"
  end
end
