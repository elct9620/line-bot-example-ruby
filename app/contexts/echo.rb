class EchoContext < Context
  def process(event)
    response = "Invalid message!"
    response = event.content[:text] if is_text?(event)
    LineAPI.client.send_text(event.from_mid, response)
    Context.store(event.from_mid, HelpContext)
  end
end
