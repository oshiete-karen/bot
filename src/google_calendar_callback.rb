require "google/apis/calendar_v3"
require "google/api_client/client_secrets"
require "mysql2"
require 'yaml'
require "json"
require "sinatra/base"

class GoogleCalendarCallback < Sinatra::Base
  enable :sessions
  set :session_secret, "setme"

  # このurlはカレンによってユーザに伝えられる。友達登録直後とか、認証してないけどコマンドとして認識できるを発言されたときとか。
  get "/auth/:id" do # インクリメンタルな数字じゃなくてハッシュ化した方がよさそう
    credentials = get_credentials_by(params[:id])
    if credentials
      client_opts = JSON.parse(credentials)
      auth_client = Signet::OAuth2::Client.new(client_opts)
      "Google Calendarの情報を参照、編集する権限は認証済みです"
    else
      session[:id] = params[:id]
      redirect to("/oauth2callback")
    end
  end

  get "/oauth2callback" do
    client_secrets = Google::APIClient::ClientSecrets.load("./config/client_secrets.json")
    auth_client = client_secrets.to_authorization
    auth_client.update!(
      :scope => "https://www.googleapis.com/auth/calendar",
      :redirect_uri => url("/oauth2callback"),
      :state => "id=#{session[:id]}")
    if request["code"] == nil
      auth_uri = auth_client.authorization_uri.to_s
      redirect to(auth_uri)
    else
      auth_client.code = request["code"]
      auth_client.fetch_access_token!
      auth_client.client_secret = nil
      update_credentials(session[:id], auth_client.to_json)
      redirect to("/auth/#{session[:id]}")
    end
  end
end

def get_credentials_by(id)
  sql = %q{SELECT google_credentials_json FROM user WHERE id = ?}
  statement = $client.prepare(sql)
  result = statement.execute(id)

  result ? result.first["google_credentials_json"] : nil
end

def get_credentials_by_mid(mid)
  sql = %q{SELECT google_credentials_json FROM user WHERE mid = ?}
  statement = $client.prepare(sql)
  result = statement.execute(mid)

  return result ? result.first["google_credentials_json"] : nil
end

def update_credentials(id, json)
  # 友達登録時にid, name, midは確定する前提
  sql = %q{UPDATE user SET google_credentials_json = ? WHERE id = ?}
  statement = $client.prepare(sql)
  result = statement.execute(json, id)

  result ? result.first : nil
end
