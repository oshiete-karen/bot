require "google/apis/calendar_v3"
require "google/api_client/client_secrets"
require "json"
require "sinatra/base"
# require "pry"

class GoogleCalendarCallback < Sinatra::Base
  enable :sessions
  set :session_secret, "setme"

  get "/auth" do
    unless session.has_key?(:credentials)
      redirect to("/oauth2callback")
    end
    client_opts = JSON.parse(session[:credentials])
    auth_client = Signet::OAuth2::Client.new(client_opts)
    "Google Calendarの情報を参照、編集する権限は認証済みです"
  end

  get "/oauth2callback" do
    client_secrets = Google::APIClient::ClientSecrets.load("./bot/client_secrets.json")
    auth_client = client_secrets.to_authorization
    auth_client.update!(
      :scope => "https://www.googleapis.com/auth/calendar",
      :redirect_uri => url("/oauth2callback"))
    if request["code"] == nil
      auth_uri = auth_client.authorization_uri.to_s
      redirect to(auth_uri)
    else
      auth_client.code = request["code"]
      auth_client.fetch_access_token!
      auth_client.client_secret = nil
      # TODO: sessionじゃなくてDBに入れる
      session[:credentials] = auth_client.to_json
      redirect to("/auth")
    end
  end
end
