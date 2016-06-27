module Application
  class HelpContext < Context

    def process(event)
      response = process_text(event, event.content[:text]) if is_text?(event)
      response ||= "Please type Upload or Echo to next process"
      LineAPI.client.send_text(event.from_mid, response)
    end

    def process_text(event, text)
      case text
      when "Upload"
        Context.store(event.from_mid, UploadContext.name)
        return "Please upload a image for me"
      when "Echo"
        Context.store(event.from_mid, EchoContext.name)
        return "Please send any thing for me"
      end
    end

  end
end
