require 'line/bot'
require 'json'

def client
  @client ||= Line::Bot::Client.new(
    channel_id: ENV['LINE_CHANNEL_ID'],
    channel_secret: ENV['LINE_CHANNEL_SECRET'],
    channel_mid: ENV['LINE_CHANNEL_MID']
  )
end

def handle_message(event)
  p event.content
  case event.content
  when Line::Bot::Message::Text
    client.send_text(event.from_mid, event.content[:text])
  when Line::Bot::Message::Image
    p "Got image!"
    client.send_image(event.from_mid, event.content[:image_url], event.content[:preview_url])
  end

end

class Application < Sinatra::Base

  get '/' do
    'Hello World'
  end

  post '/callback' do
    signature = request.env['HTTP_X_LINE_CHANNELSIGNATURE']
    unless client.certentials.validate_signature(request.body.read, signature)
      error 400 do 'Bad Request' end
    end

    request.body.rewind
    events = Line::Bot::Response.new(request.body.read)

    events.each do |event|
      case event.event_type
      when Line::Bot::Receive::EventType::MESSAGE
        handle_message(event)
      end
    end

    "OK"
  end
end
