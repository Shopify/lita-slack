require 'faraday'

require 'lita/adapters/slack/rtm_start_response'
require 'lita/adapters/slack/im_open_response'

module Lita
  module Adapters
    class Slack < Adapter
      class API
        def initialize(token, stubs = nil)
          @token = token
          @stubs = stubs
        end

        def im_open(user_id)
          response_data = call_api("im.open", user: user_id)

          IMOpenResponse.build(response_data)
        end

        def rtm_start
          response_data = call_api("rtm.start")

          RTMStartResponse.build(response_data)
        end

        private

        attr_reader :stubs
        attr_reader :token

        def call_api(method, post_data = {})
          response = connection.post(
            "https://slack.com/api/#{method}",
            { token: token }.merge(post_data)
          )

          parse_response(response, method)
        end

        def connection
          Faraday.new do |faraday|
            faraday.adapter(:test, stubs) if stubs
          end
        end

        def parse_response(response, method)
          unless response.success?
            raise "Slack API call to #{method} failed with status code #{response.status}."
          end

          MultiJson.load(response.body)
        end
      end
    end
  end
end
