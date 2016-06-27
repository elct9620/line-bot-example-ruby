module Application
  class HelpContext < Context

    def process(event)
      response = process_text(event.content[:text]) if is_text?(event)
      response ||= "Please type Upload or Echo to next process"
      LineAPI.client.send_text(event.from_mid, response)
    end

    def process_text(text)
      case text
      when "Upload"
        Context.store(event.from_mid, UploadContext)
        return "Please upload a image for me"
      when "Echo"
        Context.store(event.from_mid, EchoContext)
        return "Please send any thing for me"
      end
    end

  end
end
