require 'line/bot'

class LineController < Application::Base
  get '/' do
    error 400, "Bad Request"
  end

  post '/' do
    error 400, "Bad Request" unless is_valid_request?(request.body.read, request.env['HTTP_X_LINE_CHANNELSIGNATURE'])

    request.body.rewind
    events = Line::Bot::Response.new(request.body.read)
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
    context = Context.restore(event.from_mid)
    context.process(event)
  end
end
