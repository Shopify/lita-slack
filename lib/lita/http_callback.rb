module Lita
  class HTTPCallback
    old_call = instance_method(:call)
    define_method(:call) do |env|
      return unauthorized_response unless valid_request?(env)

      old_call.bind(self).call(env)
    end

    private

    VERSION_NUMBER = 'v0'.freeze
    FIVE_MINUTES = 5 * 30

    def valid_request?(env)
      return false if missing_signature_or_request_timestamp?(env)
      return false if request_expired?(env['HTTP_X_SLACK_REQUEST_TIMESTAMP'])
      return false unless valid_signature?(env)

      true
    end

    def missing_signature_or_request_timestamp?(env)
      !(env['HTTP_X_SLACK_SIGNATURE'] && env['HTTP_X_SLACK_REQUEST_TIMESTAMP'])
    end

    def valid_signature?(env)
      Rack::Utils.secure_compare(compute_hash_sha256(env), env['HTTP_X_SLACK_SIGNATURE'])
    end

    def request_expired?(timestamp)
      (Time.now.utc.to_i - timestamp.to_i).abs > FIVE_MINUTES
    end

    def compute_hash_sha256(env)
      timestamp = env['HTTP_X_SLACK_REQUEST_TIMESTAMP']
      payload = "#{VERSION_NUMBER}:#{timestamp}:#{request_body(env)}"
      "#{VERSION_NUMBER}=#{OpenSSL::HMAC.hexdigest('SHA256', slack_signing_secret(env["lita.robot"]), payload)}"
    end

    def request_body(env)
      return '' unless env['rack.input']

      env['rack.input'].string
    end

    def slack_signing_secret(config)
      config.adapters.slack.signing_secret
    end

    def unauthorized_response
      Rack::Response.new([], 401).finish
    end
  end
end
