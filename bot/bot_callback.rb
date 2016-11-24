require 'sinatra/base'

class Callback < Sinatra::Base
  post '/bot_callback' do
    p request.body
  end
end
