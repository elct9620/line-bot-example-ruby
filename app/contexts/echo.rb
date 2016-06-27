module Application
  class EchoContext < Context
    def process(event)
      response = event.content[:text] if is_text?(event)
      response ||= "Invalid message!"
      LineAPI.client.send_text(event.from_mid, response)
      Context.store(event.from_mid, HelpContext)
    end
  end
end
