require 'line/bot'
require 'json'

def client
  @client ||= Line::Bot::Client.new(
    channel_id: ENV['LINE_CHANNEL_ID'],
    channel_secret: ENV['LINE_CHANNEL_SECRET'],
    channel_mid: ENV['LINE_CHANNEL_MID']
  )
end

class Application < Sinatra::Base

  get '/' do
    'Hello World'
  end

  post '/callback' do
    signature = request.env['HTTP_X_LINE_CHANNELSIGNATURE']
    unless client.certentials.validate_signature?(request.body.read, signature)
      error 400 do 'Bad Request' end
    end

    request.body.rewind
    json = JSON.parse(request.body.read)
    result = json['result']

    result.each do |message|
      case message['eventType']
      when Line::Bot::Receive::EventType::MESSAGE
        client.send_text(message['content']['from'], message['content']['text'])
      end
    end

    "OK"
  end
end
