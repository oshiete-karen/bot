# Copyright 2014, Google Inc.
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are
# met:
#
#     * Redistributions of source code must retain the above copyright
# notice, this list of conditions and the following disclaimer.
#     * Redistributions in binary form must reproduce the above
# copyright notice, this list of conditions and the following disclaimer
# in the documentation and/or other materials provided with the
# distribution.
#     * Neither the name of Google Inc. nor the names of its
# contributors may be used to endorse or promote products derived from
# this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
# A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
# OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
# LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
# THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
require 'googleauth/token_store'

module Google
  module Auth
    module Stores
      class MySQLTokenStore < Google::Auth::TokenStore
        def initialize(client)
          @client = client
        end
        # Load the token data from storage for the given ID.
        #
        # @param [String] id
        #  ID of token data to load.
        # @return [String]
        #  The loaded token data.
        def load(_id)
          sql = %q{SELECT * FROM credential WHERE user_id = ?}
          statement = @client.prepare(sql)
          result = statement.execute(_id)

          result.first ? result.first.tap {|obj| obj["scope"] = JSON.parse(obj["scope"]) } : nil
        end

        # Put the token data into storage for the given ID.
        #
        # @param [String] id
        #  ID of token data to store.
        # @param [String] token
        #  The token data to store.
        def store(_id, _token_as_json)
          token = JSON.parse(_token_as_json)
          sql = %q{
            INSERT INTO credential (`user_id`, `client_id`, `access_token`, `refresh_token`, `expiration_time_millis`, `scope`)
            VALUES (?, ?, ?, ?, ?, ?)
          }
          statement = @client.prepare(sql)
          result = statement.execute(_id, token["client_id"], token["access_token"], token["refresh_token"], token["expiration_time_millis"], token["scope"].to_json)
        end

        # Remove the token data from storage for the given ID.
        #
        # @param [String] id
        #  ID of the token data to delete
        def delete(_id)
          raise 'Not implemented'
        end
      end
    end
  end
end
