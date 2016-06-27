module Application
  class UploadContext < Context
    def process(event)
      LineAPI.client.send_text(event.from_mid, "Not support this method")
      Content.store(event.from_mid, HelpContext)
    end
  end
end
