#!/usr/bin/env ruby
require 'sinatra/base'
# ここで分割したルーティングのクラスを読み込んで下さい
require './bot/bot_callback'
require './bot/google_calendar_callback'

class App < Sinatra::Base

  configure do
    set :bind, '0,0,0,0'
    set :port, 443
  end

  def self.run!
    super do |server|
      server.ssl = true
      server.ssl_options = {
        :cert_chain_file  => "/etc/pki/tls/certs/oshietekaren.crt",
        :private_key_file => "/etc/pki/tls/certs/oshietekaren.key",
        :verify_peer      => false
      }
    end
  end

  get '/' do
    'Hello,SSL'
  end

  # use Hoge のように分割したクラスを読み込むことができます。

  use BotCallback
  use GoogleCalendarCallback
end

$config = YAML.load_file('./config.yaml')
$client = Mysql2::Client.new($config["db"])

run App
