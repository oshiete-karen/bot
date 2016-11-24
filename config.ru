#!/usr/bin/env ruby
require 'sinatra/base'
# ここで分割したルーティングのクラスを読み込んで下さい
require './bot/bot_callback'
require './bot/google_calendar_callback'

class App < Sinatra::Base
  # use Hoge のように分割したクラスを読み込むことができます。
  use BotCallback
  use GoogleCalendarCallback
end

run App
