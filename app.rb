
require './client'

def client
  @client ||= Client.new(
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
    unless client.validate_signature(request.body.read, signature)
      error 400 do 'Bad Request' end
    end

    puts "Valid!!"

    "OK"
  end
end
