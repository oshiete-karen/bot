#!/usr/bin/env ruby
# $:.unshift File.dirname(__FILE__)
require 'sinatra/base'
# ここで分割したルーティングのクラスを読み込んで下さい
require './bot/bot_callback'

class App < Sinatra::Base
  # use Hoge のように分割したクラスを読み込むことができます。
  use Callback
end

run App
