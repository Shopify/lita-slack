require "spec_helper"
require_relative '../../lib/lita/http_callback'

describe Lita::HTTPCallback do

  let(:lita_robot) { double('lita_robot') }
  let(:http_callback) { Lita::HTTPCallback.new nil, nil }
  let(:config) { Lita::Adapters::Slack.configuration_builder.build }

  before do
    config.signing_secret = '46277e8f4e9d54febae94252ae3c306a'
    allow(lita_robot).to receive_message_chain('config.adapters.slack').and_return(config)
    allow_any_instance_of(Rack::Request).to receive(:head?).and_return(true)
  end

  context 'Request has a valid signature and hasn\'t expired yet' do
    it 'returns 204' do
      expect(http_callback.call(build_request).first).to eq(204)
    end
  end

  context 'Request Timestamp has expired 5 minutes ago' do
    it 'returns 401' do
      expect(http_callback.call(build_request(request_timestamp: timestamp - FIVE_MINUTES)).first).to eq(401)
    end
  end

  context 'Request has an invalid signature' do
    it 'returns 401' do
      expect(http_callback.call(build_request(request_signature: 'invalid signature')).last.status).to eq(401)
    end
  end

  context 'Request is missing request signature' do
    it 'returns 401' do
      expect(http_callback.call(build_request(request_signature: nil)).last.status).to eq(401)
    end
  end

  context 'Request is missing request timestamp' do
    it 'returns 401' do
      expect(http_callback.call(build_request(request_timestamp: nil)).last.status).to eq(401)
    end
  end

  context 'Request is missing request timestamp and signature' do
    it 'returns 401' do
      expect(http_callback.call(build_request(request_signature: nil, request_timestamp: nil)).last.status).to eq(401)
    end
  end

  private

  FIVE_MINUTES = 5 * 60

  def build_request(request_body: rack_input, request_signature: signature, request_timestamp: timestamp)
    {
      'rack.input' => request_body,
      'HTTP_X_SLACK_SIGNATURE' => request_signature,
      'HTTP_X_SLACK_REQUEST_TIMESTAMP' => request_timestamp,
      'lita.robot' => lita_robot
    }
  end

  def timestamp
    @timestamp ||= Time.now.utc.to_i
  end

  def signature
    "v0=#{OpenSSL::HMAC.hexdigest('SHA256', config.signing_secret, "v0:#{timestamp}:SomePayload")}"
  end

  def rack_input
    @rack_input ||= StringIO.new('SomePayload')
  end
end
