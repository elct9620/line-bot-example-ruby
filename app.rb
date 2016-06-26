require 'line/bot'
require 'json'
require 'base64'
require 'securerandom'

def client
  @client ||= Line::Bot::Client.new(
    channel_id: ENV['LINE_CHANNEL_ID'],
    channel_secret: ENV['LINE_CHANNEL_SECRET'],
    channel_mid: ENV['LINE_CHANNEL_MID']
  )
end

def redis
  @redis ||= Redis.new(url: ENV['REDIS_URL'])
end

def get_image_information(id)
  response = client.get_image(id)

  {
    type: response['Content-Type'],
    body: Base64.strict_encode64(response.body)
  }
end

def handle_message(event)
  case event.content
  when Line::Bot::Message::Text
    client.send_text(event.from_mid, event.content[:text])
  when Line::Bot::Message::Image
    puts "Got image with ID: #{event.id}"

    hash = SecureRandom.hex(24)
    redis.set hash, get_image_information(event.id).to_json

    url = "#{ENV['APP_HOST']}/image/#{hash}"
    client.send_text(event.from_mid, url)
  end

end

class Application < Sinatra::Base

  get '/' do
    'Hello World'
  end

  get '/image/:id' do
    data = redis.get(params['id'])
    error 404 do "Image Not Found" end if data.nil?
    data = JSON.parse(data)

    content_type data[:type]
    Base64.strict_decode64(data[:body])
  end

  post '/callback' do
    signature = request.env['HTTP_X_LINE_CHANNELSIGNATURE']
    unless client.certentials.validate_signature(request.body.read, signature)
      error 400 do 'Bad Request' end
    end

    request.body.rewind
    events = Line::Bot::Response.new(request.body.read)
    request.body.rewind
    puts request.body.read


    events.each do |event|
      case event.event_type
      when Line::Bot::Receive::EventType::MESSAGE
        handle_message(event)
      end
    end

    "OK"
  end
end
