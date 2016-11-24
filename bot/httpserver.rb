#!/usr/bin/env ruby
require 'webrick'
include WEBrick

server = HTTPServer.new(
    :Port => 8000,
    :DocumentRoot => File.join(Dir::pwd, "public_html"),
    :CGIInterpreter => '/usr/bin/ruby'
)
trap("INT"){ server.shutdown }

server.mount('/bot_callback', WEBrick::HTTPServlet::CGIHandler, './bot_callback.rb')

# server.mount_proc '/hoge' do |req, res|
#   # res.body = req.query['a']
#   res.body = 'aiueo'
# end


server.start
