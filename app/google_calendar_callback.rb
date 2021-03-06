require 'sinatra/base'
require 'googleauth'
require 'mysql2'
require 'yaml'
require 'json'
require './app/mysql_token_store'

class GoogleCalendarCallback < Sinatra::Base
  enable :sessions

  @@config = YAML.load_file('./config/config.yaml')
  @@scope = ['https://www.googleapis.com/auth/calendar.readonly']
  @@mysql_client = Mysql2::Client.new(@@config['db'])
  @@client_id = Google::Auth::ClientId.from_file('./config/client_secrets.json')
  @@token_store = Google::Auth::Stores::MySQLTokenStore.new(@@mysql_client)
  @@authorizer = Google::Auth::WebUserAuthorizer.new(@@client_id, @@scope, @@token_store, '/api/oauth2callback')
  OOB_URI = 'https://oshietekaren.info'

  # このurlはカレンによってユーザに伝えられる。友達登録直後とか、認証してないけどコマンドとして認識できるを発言されたときとか。
  get '/api/auth/:id' do # インクリメンタルな数字じゃなくてハッシュ化した方がよさそう
    user_id = params['id']
    credentials = @@authorizer.get_credentials(user_id, request)
    if credentials.nil?
      redirect @@authorizer.get_authorization_url(login_hint: user_id, request: request, base_url: OOB_URI)
    end

    'Google Calendarの参照権限をカレンちゃんに渡しました。LINEの画面に戻って操作を続けて下さい。'
  end

  get '/api/oauth2callback' do
    target_url = Google::Auth::WebUserAuthorizer.handle_auth_callback_deferred(
      request)
    redirect target_url
  end
end
