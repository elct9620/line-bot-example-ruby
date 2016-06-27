require 'line/bot'

class LineAPI
  class << self
    def client
      @client ||= Line::Bot::Client.new(
        channel_id: ENV['LINE_CHANNEL_ID'],
        channel_secret: ENV['LINE_CHANNEL_SECRET'],
        channel_mid: ENV['LINE_CHANNEL_MID']
      )
    end

    def validate_signature(body, request)
      client.certentials.validate_signature(body, request)
    end
  end
end
