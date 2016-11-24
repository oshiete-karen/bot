require 'sinatra/base'
require 'pry'

class BotCallback < Sinatra::Base
  post '/bot_callback' do
    # これを入れるとブレークポイントになってデバッグできます。require 'pry'が必要です。
    # binding.pry
    "ok"
  end
end
