require 'line/bot'

class LineController < Application::Base
  get '/' do
    error 400, "Bad Request" unless is_valid_request?(request.body, request.env['HTTP_X_LINE_CHANNELSIGNATURE'])

    events = Line::Bot::Response.new(request.body)
    events.each do |event|
      process_event(event)
    end

    "OK"
  end

  def is_valid_request?(body, signature)
    LineAPI.validate_signature(body, signature)
  end

  def process_event(event)
    case event.event_type
    when Line::Bot::Receive::EventType::MESSAGE
      process_message(event)
    end
  end

  def process_message(event)
    case event.content
    when Line::Bot::Message::Text
      LineAPI.client.send_text(event.from_mid, "Receive Test!")
    when Line::Bot::Message::Image
      LineAPI.client.send_text(event.from_mid, "Receive Image")
    end
  end
end
