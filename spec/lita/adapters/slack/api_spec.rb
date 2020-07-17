require "spec_helper"

describe Lita::Adapters::Slack::API do
  subject { described_class.new(config, stubs) }

  let(:http_status) { 200 }
  let(:token) { 'abcd-1234567890-hWYd21AmMH2UHAkx29vb5c1Y' }
  let(:config) { Lita::Adapters::Slack.configuration_builder.build }

  before do
    config.token = token
  end

  describe "#im_open" do
    let(:channel_id) { 'D024BFF1M' }
    let(:stubs) do
      Faraday::Adapter::Test::Stubs.new do |stub|
        stub.post('https://slack.com/api/im.open', token: token, user: user_id) do
          [http_status, {}, http_response]
        end
      end
    end
    let(:user_id) { 'U023BECGF' }

    describe "with a successful response" do
      let(:http_response) do
        MultiJson.dump({
            ok: true,
            channel: {
                id: 'D024BFF1M'
            }
        })
      end

      it "returns a response with the IM's ID" do
        response = subject.im_open(user_id)

        expect(response.id).to eq(channel_id)
      end
    end

    describe "with a Slack error" do
      let(:http_response) do
        MultiJson.dump({
          ok: false,
          error: 'invalid_auth'
        })
      end

      it "raises a RuntimeError" do
        expect { subject.im_open(user_id) }.to raise_error(
          "Slack API call to im.open returned an error: invalid_auth."
        )
      end
    end

    describe "with an HTTP error" do
      let(:http_status) { 422 }
      let(:http_response) { '' }

      it "raises a RuntimeError" do
        expect { subject.im_open(user_id) }.to raise_error(
          "Slack API call to im.open failed with status code 422: ''. Headers: {}"
        )
      end
    end
  end

  describe "#channels_info" do
    let(:channel_id) { 'C024BE91L' }
    let(:stubs) do
      Faraday::Adapter::Test::Stubs.new do |stub|
        stub.post('https://slack.com/api/channels.info', token: token, channel: channel_id) do
          [http_status, {}, http_response]
        end
      end
    end

    describe "with a successful response" do
      let(:http_response) do
        MultiJson.dump({
            ok: true,
            channel: {
                id: 'C024BE91L'
            }
        })
      end

      it "returns a response with the Channel's ID" do
        response = subject.channels_info(channel_id)

        expect(response['channel']['id']).to eq(channel_id)
      end
    end

    describe "with a Slack error" do
      let(:http_response) do
        MultiJson.dump({
          ok: false,
          error: 'channel_not_found'
        })
      end

      it "raises a RuntimeError" do
        expect { subject.channels_info(channel_id) }.to raise_error(
          "Slack API call to channels.info returned an error: channel_not_found."
        )
      end
    end

    describe "with an HTTP error" do
      let(:http_status) { 422 }
      let(:http_response) { '' }

      it "raises a RuntimeError" do
        expect { subject.channels_info(channel_id) }.to raise_error(
          "Slack API call to channels.info failed with status code 422: ''. Headers: {}"
        )
      end
    end
  end

  describe "#channels_list" do
    let(:channel_id) { 'C024BE91L' }
    let(:stubs) do
      Faraday::Adapter::Test::Stubs.new do |stub|
        stub.post('https://slack.com/api/conversations.list', token: token, types: 'public_channel') do
          [http_status, {}, http_response]
        end
      end
    end

    describe "with a successful response" do
      let(:http_response) do
        MultiJson.dump({
            ok: true,
            channels: [{
                id: 'C024BE91L'
            }]
        })
      end

      it "returns a response with the Channel's ID" do
        response = subject.channels_list

        expect(response['channels'].first['id']).to eq(channel_id)
      end
    end

    describe "with parameters" do
      let(:stubs) do
        Faraday::Adapter::Test::Stubs.new do |stub|
          stub.post('https://slack.com/api/conversations.list', token: token, types: 'public_channel', exclude_archived: true) do
            [http_status, {}, http_response]
          end
        end
      end
      let(:http_response) do
        MultiJson.dump({
            ok: true,
            channels: [{
                id: 'C024BE91L',
                is_archived: false,
            }]
        })
      end

      it "returns a response with the Channel's ID" do
        response = subject.channels_list(params: { exclude_archived: true })

        expect(response['channels'].first['id']).to eq(channel_id)
      end
    end

    describe "with a Slack error" do
      let(:http_response) do
        MultiJson.dump({
          ok: false,
          error: 'invalid_auth'
        })
      end

      it "raises a RuntimeError" do
        expect { subject.channels_list }.to raise_error(
          "Slack API call to conversations.list returned an error: invalid_auth."
        )
      end
    end

    describe "with an HTTP error" do
      let(:http_status) { 422 }
      let(:http_response) { '' }

      it "raises a RuntimeError" do
        expect { subject.channels_list }.to raise_error(
          "Slack API call to conversations.list failed with status code 422: ''. Headers: {}"
        )
      end
    end
  end

  describe "#groups_list" do
    let(:channel_id) { 'G024BE91L' }
    let(:stubs) do
      Faraday::Adapter::Test::Stubs.new do |stub|
        stub.post('https://slack.com/api/conversations.list', token: token, types: 'private_channel') do
          [http_status, {}, http_response]
        end
      end
    end

    describe "with a successful response" do
      let(:http_response) do
        MultiJson.dump({
            ok: true,
            channels: [{
                id: 'G024BE91L'
            }]
        })
      end

      it "returns a response with groupss Channel ID's" do
        response = subject.groups_list

        expect(response['groups'].first['id']).to eq(channel_id)
      end
    end

    describe "with a Slack error" do
      let(:http_response) do
        MultiJson.dump({
          ok: false,
          error: 'invalid_auth'
        })
      end

      it "raises a RuntimeError" do
        expect { subject.groups_list }.to raise_error(
          "Slack API call to conversations.list returned an error: invalid_auth."
        )
      end
    end

    describe "with an HTTP error" do
      let(:http_status) { 422 }
      let(:http_response) { '' }

      it "raises a RuntimeError" do
        expect { subject.groups_list }.to raise_error(
          "Slack API call to conversations.list failed with status code 422: ''. Headers: {}"
        )
      end
    end
  end

  describe "#mpim_list" do
    let(:channel_id) { 'G024BE91L' }
    let(:stubs) do
      Faraday::Adapter::Test::Stubs.new do |stub|
        stub.post('https://slack.com/api/conversations.list', token: token, types: 'mpim') do
          [http_status, {}, http_response]
        end
      end
    end

    describe "with a successful response" do
      let(:http_response) do
        MultiJson.dump({
            ok: true,
            channels: [{
                id: 'G024BE91L'
            }]
        })
      end

      it "returns a response with MPIMs Channel ID's" do
        response = subject.mpim_list

        expect(response['groups'].first['id']).to eq(channel_id)
      end
    end

    describe "with a Slack error" do
      let(:http_response) do
        MultiJson.dump({
          ok: false,
          error: 'invalid_auth'
        })
      end

      it "raises a RuntimeError" do
        expect { subject.mpim_list }.to raise_error(
          "Slack API call to conversations.list returned an error: invalid_auth."
        )
      end
    end

    describe "with an HTTP error" do
      let(:http_status) { 422 }
      let(:http_response) { '' }

      it "raises a RuntimeError" do
        expect { subject.mpim_list }.to raise_error(
          "Slack API call to conversations.list failed with status code 422: ''. Headers: {}"
        )
      end
    end
  end

  describe "#im_list" do
    let(:channel_id) { 'D024BFF1M' }
    let(:stubs) do
      Faraday::Adapter::Test::Stubs.new do |stub|
        stub.post('https://slack.com/api/conversations.list', token: token, types: 'im') do
          [http_status, {}, http_response]
        end
      end
    end

    describe "with a successful response" do
      let(:http_response) do
        MultiJson.dump({
            ok: true,
            channels: [{
                id: 'D024BFF1M'
            }]
        })
      end

      it "returns a response with IMs Channel ID's" do
        response = subject.im_list

        expect(response['ims'].first['id']).to eq(channel_id)
      end
    end

    describe "with a Slack error" do
      let(:http_response) do
        MultiJson.dump({
          ok: false,
          error: 'invalid_auth'
        })
      end

      it "raises a RuntimeError" do
        expect { subject.im_list }.to raise_error(
          "Slack API call to conversations.list returned an error: invalid_auth."
        )
      end
    end

    describe "with an HTTP error" do
      let(:http_status) { 422 }
      let(:http_response) { '' }

      it "raises a RuntimeError" do
        expect { subject.im_list }.to raise_error(
          "Slack API call to conversations.list failed with status code 422: ''. Headers: {}"
        )
      end
    end
  end

  describe "#send_attachments" do
    let(:attachment) do
      Lita::Adapters::Slack::Attachment.new(attachment_text)
    end
    let(:attachment_text) { "attachment text" }
    let(:attachment_hash) do
      {
        fallback: fallback_text,
        text: attachment_text,
      }
    end
    let(:fallback_text) { attachment_text }
    let(:http_response) { MultiJson.dump({ ok: true }) }
    let(:room) { Lita::Room.new("C1234567890") }
    let(:stubs) do
      Faraday::Adapter::Test::Stubs.new do |stub|
        stub.post(
          "https://slack.com/api/chat.postMessage",
          token: token,
          as_user: true,
          channel: room.id,
          attachments: MultiJson.dump([attachment_hash]),
        ) do
          [http_status, {}, http_response]
        end
      end
    end

    context "with a simple text attachment" do
      it "sends the attachment" do
        response = subject.send_attachments(room, [attachment])

        expect(response['ok']).to be(true)
      end
    end

    context "with a different fallback message" do
      let(:attachment) do
        Lita::Adapters::Slack::Attachment.new(attachment_text, fallback: fallback_text)
      end
      let(:fallback_text) { "fallback text" }

      it "sends the attachment" do
        response = subject.send_attachments(room, [attachment])

        expect(response['ok']).to be(true)
      end
    end

    context "with all the valid options" do
      let(:attachment) do
        Lita::Adapters::Slack::Attachment.new(attachment_text, common_hash_data)
      end
      let(:attachment_hash) do
        common_hash_data.merge(fallback: attachment_text, text: attachment_text)
      end
      let(:common_hash_data) do
        {
          author_icon: "http://example.com/author.jpg",
          author_link: "http://example.com/author",
          author_name: "author name",
          color: "#36a64f",
          fields: [{
            title: "priority",
            value: "high",
            short: true,
          }, {
            title: "super long field title",
            value: "super long field value",
            short: false,
          }],
          image_url: "http://example.com/image.jpg",
          pretext: "pretext",
          thumb_url: "http://example.com/thumb.jpg",
          title: "title",
          title_link: "http://example.com/title",
        }
      end

      it "sends the attachment" do
        response = subject.send_attachments(room, [attachment])

        expect(response['ok']).to be(true)
      end
    end

    context "with a Slack error" do
      let(:http_response) do
        MultiJson.dump({
          ok: false,
          error: 'invalid_auth'
        })
      end

      it "raises a RuntimeError" do
        expect { subject.send_attachments(room, [attachment]) }.to raise_error(
          "Slack API call to chat.postMessage returned an error: invalid_auth."
        )
      end
    end

    context "with an HTTP error" do
      let(:http_status) { 422 }
      let(:http_response) { '' }

      it "raises a RuntimeError" do
        expect { subject.send_attachments(room, [attachment]) }.to raise_error(
          "Slack API call to chat.postMessage failed with status code 422: ''. Headers: {}"
        )
      end
    end
  end

  describe "#send_messages" do
    let(:messages) { ["attachment text"] }
    let(:http_response) { MultiJson.dump({ ok: true }) }
    let(:room) { "C1234567890" }
    let(:stubs) do
      Faraday::Adapter::Test::Stubs.new do |stub|
        stub.post(
          "https://slack.com/api/chat.postMessage",
          token: token,
          as_user: true,
          channel: room,
          text: messages.join("\n"),
        ) do
          [http_status, {}, http_response]
        end
      end
    end

    context "with a simple text attachment" do
      it "sends the attachment" do
        response = subject.send_messages(room, messages)

        expect(response['ok']).to be(true)
      end
    end

    context "with configuration" do
      before do
        allow(config).to receive(:link_names).and_return(true)
      end

      def stubs(postMessage_options = {})
        Faraday::Adapter::Test::Stubs.new do |stub|
          stub.post(
            "https://slack.com/api/chat.postMessage",
            token: token,
            link_names: 1,
            as_user: true,
            channel: room,
            text: messages.join("\n"),
          ) do
            [http_status, {}, http_response]
          end
        end
      end

      it "sends the message with configuration" do
        response = subject.send_messages(room, messages)

        expect(response['ok']).to be(true)
      end
    end

    context "with a different fallback message" do
      let(:attachment) do
        Lita::Adapters::Slack::Attachment.new(attachment_text, fallback: fallback_text)
      end
      let(:fallback_text) { "fallback text" }

      it "sends the attachment" do
        response = subject.send_messages(room, messages)

        expect(response['ok']).to be(true)
      end
    end

    context "with all the valid options" do
      let(:attachment) do
        Lita::Adapters::Slack::Attachment.new(attachment_text, common_hash_data)
      end
      let(:attachment_hash) do
        common_hash_data.merge(fallback: attachment_text, text: attachment_text)
      end
      let(:common_hash_data) do
        {
          author_icon: "http://example.com/author.jpg",
          author_link: "http://example.com/author",
          author_name: "author name",
          color: "#36a64f",
          fields: [{
            title: "priority",
            value: "high",
            short: true,
          }, {
            title: "super long field title",
            value: "super long field value",
            short: false,
          }],
          image_url: "http://example.com/image.jpg",
          pretext: "pretext",
          thumb_url: "http://example.com/thumb.jpg",
          title: "title",
          title_link: "http://example.com/title",
        }
      end

      it "sends the attachment" do
        response = subject.send_messages(room, messages)

        expect(response['ok']).to be(true)
      end
    end

    context "with a Slack error" do
      let(:http_response) do
        MultiJson.dump({
          ok: false,
          error: 'invalid_auth'
        })
      end

      it "raises a RuntimeError" do
        expect { subject.send_messages(room, messages) }.to raise_error(
          "Slack API call to chat.postMessage returned an error: invalid_auth."
        )
      end
    end

    context "with an HTTP error" do
      let(:http_status) { 422 }
      let(:http_response) { '' }

      it "raises a RuntimeError" do
        expect { subject.send_messages(room, messages) }.to raise_error(
          "Slack API call to chat.postMessage failed with status code 422: ''. Headers: {}"
        )
      end
    end
  end

  describe "#send_ephemeral_attachments" do
    let(:attachment) do
      Lita::Adapters::Slack::Attachment.new(attachment_text)
    end
    let(:attachment_text) { "attachment text" }
    let(:attachment_hash) do
      {
          fallback: fallback_text,
          text: attachment_text,
      }
    end
    let(:fallback_text) { attachment_text }
    let(:http_response) { MultiJson.dump({ ok: true }) }
    let(:room) { Lita::Room.new("C1234567890") }
    let(:user) { Lita::User.new('U023BECGF') }
    let(:stubs) do
      Faraday::Adapter::Test::Stubs.new do |stub|
        stub.post(
            "https://slack.com/api/chat.postEphemeral",
            token: token,
            as_user: true,
            user: user.id,
            channel: room.id,
            attachments: MultiJson.dump([attachment_hash]),
            ) do
          [http_status, {}, http_response]
        end
      end
    end

    context "with a simple text attachment" do
      it "sends the attachment" do
        response = subject.send_ephemeral_attachments(room, user,[attachment])

        expect(response['ok']).to be(true)
      end
    end

    context "with a Slack error" do
      let(:http_response) do
        MultiJson.dump({
                           ok: false,
                           error: 'invalid_auth'
                       })
      end

      it "raises a RuntimeError" do
        expect { subject.send_ephemeral_attachments(room, user,[attachment]) }.to raise_error(
                                                                                      "Slack API call to chat.postEphemeral returned an error: invalid_auth."
                                                                                  )
      end
    end

    context "with an HTTP error" do
      let(:http_status) { 422 }
      let(:http_response) { '' }

      it "raises a RuntimeError" do
        expect { subject.send_ephemeral_attachments(room, user,[attachment]) }.to raise_error(
                                                                                      "Slack API call to chat.postEphemeral failed with status code 422: ''. Headers: {}"
                                                                                  )
      end
    end
  end

  describe "#send_ephemeral_messages" do
    let(:messages) { ["foo", "bar"] }
    let(:http_response) { MultiJson.dump({ ok: true }) }
    let(:room) { Lita::Room.new("C1234567890") }
    let(:user) { Lita::User.new('U023BECGF') }
    let(:stubs) do
      Faraday::Adapter::Test::Stubs.new do |stub|
        stub.post(
            "https://slack.com/api/chat.postEphemeral",
            token: token,
            as_user: true,
            channel: room.id,
            user: user.id,
            text: messages.join("\n"),
            ) do
          [http_status, {}, http_response]
        end
      end
    end

    it "sends the ephemeral message" do
      response = subject.send_ephemeral_messages(room, user, messages)

      expect(response['ok']).to be(true)
    end

    context "with a Slack error" do
      let(:http_response) do
        MultiJson.dump({
                           ok: false,
                           error: 'invalid_auth'
                       })
      end

      it "raises a RuntimeError" do
        expect { subject.send_ephemeral_messages(room, user, messages) }.to raise_error(
                                                                                "Slack API call to chat.postEphemeral returned an error: invalid_auth."
                                                                            )
      end
    end

    context "with an HTTP error" do
      let(:http_status) { 422 }
      let(:http_response) { '' }

      it "raises a RuntimeError" do
        expect { subject.send_ephemeral_messages(room, user, messages) }.to raise_error(
                                                                                "Slack API call to chat.postEphemeral failed with status code 422: ''. Headers: {}"
                                                                            )
      end
    end
  end

  describe "#reply_in_thread" do
    let(:messages) { ["attachment text"] }
    let(:http_response) { MultiJson.dump({ ok: true }) }
    let(:room) { "C1234567890" }
    let(:thread_ts) { 12346567 }
    let(:stubs) do
      Faraday::Adapter::Test::Stubs.new do |stub|
        stub.post(
          "https://slack.com/api/chat.postMessage",
          token: token,
          as_user: true,
          channel: room,
          text: messages.join("\n"),
          thread_ts: thread_ts,
        ) do
          [http_status, {}, http_response]
        end
      end
    end

    context "with a simple text attachment" do
      it "sends the attachment" do
        response = subject.reply_in_thread(room, messages, thread_ts)

        expect(response['ok']).to be(true)
      end
    end

    context "with configuration" do
      before do
        allow(config).to receive(:link_names).and_return(true)
      end

      def stubs(postMessage_options = {})
        Faraday::Adapter::Test::Stubs.new do |stub|
          stub.post(
            "https://slack.com/api/chat.postMessage",
            token: token,
            as_user: true,
            channel: room,
            text: messages.join("\n"),
            thread_ts: thread_ts,
          ) do
            [http_status, {}, http_response]
          end
        end
      end

      it "sends the message with configuration" do
        response = subject.reply_in_thread(room, messages, thread_ts)

        expect(response['ok']).to be(true)
      end
    end

    context "with a different fallback message" do
      let(:attachment) do
        Lita::Adapters::Slack::Attachment.new(attachment_text, fallback: fallback_text)
      end
      let(:fallback_text) { "fallback text" }

      it "sends the attachment" do
        response = subject.reply_in_thread(room, messages, thread_ts)

        expect(response['ok']).to be(true)
      end
    end

    context "with all the valid options" do
      let(:attachment) do
        Lita::Adapters::Slack::Attachment.new(attachment_text, common_hash_data)
      end
      let(:attachment_hash) do
        common_hash_data.merge(fallback: attachment_text, text: attachment_text)
      end
      let(:common_hash_data) do
        {
          author_icon: "http://example.com/author.jpg",
          author_link: "http://example.com/author",
          author_name: "author name",
          color: "#36a64f",
          fields: [{
            title: "priority",
            value: "high",
            short: true,
          }, {
            title: "super long field title",
            value: "super long field value",
            short: false,
          }],
          image_url: "http://example.com/image.jpg",
          pretext: "pretext",
          thumb_url: "http://example.com/thumb.jpg",
          title: "title",
          title_link: "http://example.com/title",
        }
      end

      it "sends the attachment" do
        response = subject.reply_in_thread(room, messages, thread_ts)

        expect(response['ok']).to be(true)
      end
    end

    context "with a Slack error" do
      let(:http_response) do
        MultiJson.dump({
          ok: false,
          error: 'invalid_auth'
        })
      end

      it "raises a RuntimeError" do
        expect { subject.reply_in_thread(room, messages, thread_ts) }.to raise_error(
          "Slack API call to chat.postMessage returned an error: invalid_auth."
        )
      end
    end

    context "with an HTTP error" do
      let(:http_status) { 422 }
      let(:http_response) { '' }

      it "raises a RuntimeError" do
        expect { subject.reply_in_thread(room, messages, thread_ts) }.to raise_error(
          "Slack API call to chat.postMessage failed with status code 422: ''. Headers: {}"
        )
      end
    end
  end

  describe "#set_topic" do
    let(:channel) { 'C1234567890' }
    let(:topic) { 'Topic' }
    let(:stubs) do
      Faraday::Adapter::Test::Stubs.new do |stub|
        stub.post(
          'https://slack.com/api/channels.setTopic',
          token: token,
          channel: channel,
          topic: topic
        ) do
          [http_status, {}, http_response]
        end
      end
    end

    context "with a successful response" do
      let(:http_response) do
        MultiJson.dump({
          ok: true,
          topic: 'Topic'
        })
      end

      it "returns a response with the channel's topic" do
        response = subject.set_topic(channel, topic)

        expect(response['topic']).to eq(topic)
      end
    end

    context "with a Slack error" do
      let(:http_response) do
        MultiJson.dump({
          ok: false,
          error: 'invalid_auth'
        })
      end

      it "raises a RuntimeError" do
        expect { subject.set_topic(channel, topic) }.to raise_error(
          "Slack API call to channels.setTopic returned an error: invalid_auth."
        )
      end
    end

    context "with an HTTP error" do
      let(:http_status) { 422 }
      let(:http_response) { '' }

      it "raises a RuntimeError" do
        expect { subject.set_topic(channel, topic) }.to raise_error(
          "Slack API call to channels.setTopic failed with status code 422: ''. Headers: {}"
        )
      end
    end
  end

  describe "#rtm_start" do
    let(:http_status) { 200 }
    let(:stubs) do
      Faraday::Adapter::Test::Stubs.new do |stub|
        stub.post('https://slack.com/api/rtm.start', token: token) do
          [http_status, {}, http_response]
        end
      end
    end

    describe "with a successful response" do
      let(:http_response) do
        MultiJson.dump({
          ok: true,
          url: 'wss://example.com/',
          users: [{ id: 'U023BECGF' }],
          ims: [{ id: 'D024BFF1M' }],
          self: { id: 'U12345678' },
          channels: [{ id: 'C1234567890' }],
          groups: [{ id: 'G0987654321' }],
        })
      end

      it "has data on the bot user" do
        response = subject.rtm_start

        expect(response.self.id).to eq('U12345678')
      end

      it "has an array of IMs" do
        response = subject.rtm_start

        expect(response.ims[0].id).to eq('D024BFF1M')
      end

      it "has an array of users" do
        response = subject.rtm_start

        expect(response.users[0].id).to eq('U023BECGF')
      end

      it "has a WebSocket URL" do
        response = subject.rtm_start

        expect(response.websocket_url).to eq('wss://example.com/')
      end
    end
  end

  describe "#conversations_list" do
    describe "#conversations_list" do
      let(:channel_id) { 'C024G4BGW' }
      let(:channel_id_2) { 'C024G4BGY' }
      let(:stubs) do
        Faraday::Adapter::Test::Stubs.new do |stub|
          stub.post('https://slack.com/api/conversations.list', token: token, limit: 1, types: "public_channel") do
            [http_status, {}, http_response]
          end
          stub.post('https://slack.com/api/conversations.list', token: token, limit: 1, types: "public_channel", cursor: "dGVhbTpDMDI0RzRCR1k=") do
            [http_status, {}, http_response_2]
          end
        end
      end
  
      describe "with a successful response" do
        let(:http_response) do
          MultiJson.dump({
            
            "ok": true,
            "channels": [
                {
                    "id": "C024G4BGW",
                    "name": "announcements",
                    "is_channel": true,
                    "is_group": false,
                    "is_im": false,
                    "created": 1383618685,
                    "is_archived": false,
                    "is_general": true,
                    "unlinked": 0,
                    "name_normalized": "announcements",
                    "is_shared": false,
                    "parent_conversation": nil,
                    "creator": "U024G4BGS",
                    "is_ext_shared": false,
                    "is_org_shared": false,
                    "shared_team_ids": [
                        "T024G4BGQ"
                    ],
                    "pending_shared": [],
                    "pending_connected_team_ids": [],
                    "is_pending_ext_shared": false,
                    "is_member": true,
                    "is_private": false,
                    "is_mpim": false,
                    "topic": {
                        "value": "This channel goes to *all* of Shopify. Use #random for discussion about announcements.",
                        "creator": "U031JV1FB",
                        "last_set": 1428603629
                    },
                    "purpose": {
                        "value": "The #announcements channel is for team-wide communication and announcements. All team members are in this channel.",
                        "creator": "U030SUJBJ",
                        "last_set": 1417712247
                    },
                    "previous_names": [
                        "general"
                    ],
                    "num_members": 6735
                }
            ],
            "response_metadata": {
                "next_cursor": "dGVhbTpDMDI0RzRCR1k="
            }
          
          })
        end

        let(:http_response_2) do
          MultiJson.dump({
            "ok": true,
            "channels": [
                {
                    "id": "C024G4BGY",
                    "name": "random",
                    "is_channel": true,
                    "is_group": false,
                    "is_im": false,
                    "created": 1383618685,
                    "is_archived": false,
                    "is_general": false,
                    "unlinked": 0,
                    "name_normalized": "random",
                    "is_shared": false,
                    "parent_conversation": nil,
                    "creator": "U024G4BGS",
                    "is_ext_shared": false,
                    "is_org_shared": false,
                    "shared_team_ids": [
                        "T024G4BGQ"
                    ],
                    "pending_shared": [],
                    "pending_connected_team_ids": [],
                    "is_pending_ext_shared": false,
                    "is_member": false,
                    "is_private": false,
                    "is_mpim": false,
                    "topic": {
                        "value": "Open Bar 3.0",
                        "creator": "U030TGHMQ",
                        "last_set": 1416324878
                    },
                    "purpose": {
                        "value": "A place for non-work banter, links, articles of interest, humor or anything else which you'd like concentrated in some place other than work-related channels.",
                        "creator": "",
                        "last_set": 0
                    },
                    "previous_names": [],
                    "num_members": 2341
                }
            ],
            "response_metadata": {
                "next_cursor": nil
            }
          })
        end
  
        it "returns a response with the Channel's ID" do
          response = subject.conversations_list(params: { limit: 1 })

          expect(response['channels'].size).to eq(2)
          expect(response['channels'].first['id']).to eq(channel_id)
          expect(response['channels'][1]['id']).to eq(channel_id_2)
        end
      end
  
      describe "with a Slack error" do
        let(:http_response) do
          MultiJson.dump({
            ok: false,
            error: 'invalid_auth'
          })
        end
  
        it "raises a RuntimeError" do
          expect { subject.conversations_list(params: { limit: 1 }) }.to raise_error(
            "Slack API call to conversations.list returned an error: invalid_auth."
          )
        end
      end
  
      describe "with an HTTP error" do
        let(:http_status) { 422 }
        let(:http_response) { '' }
  
        it "raises a RuntimeError" do
          expect { subject.conversations_list(params: { limit: 1 }) }.to raise_error(
            "Slack API call to conversations.list failed with status code 422: ''. Headers: {}"
          )
        end
      end
    end
  end
end
