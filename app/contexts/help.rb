module Application
  class HelpContext < Context

    def process(event)
      response = process_text(event, event.content[:text]) if is_text?(event)
      response ||= "Please type Upload or Echo, Image to next process. Type Help for command detial."
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
      when "Help", "?"
        return %{
          The robot can process below command ---
          Upload: upload a image
          Echo: return same message from you
          Image: get latest upload image
        }
      when "Image"
        # TODO: Split below code into it's own context
        latest_image_hash = get_latest_image_hash
        if latest_image_hash
          image_url = "#{ENV['APP_HOST']}/image/#{latest_image_hash}"
          LineAPI.client.send_image(event.from_mid, image_url, image_url)
          return "Ok, the latest image I alreay sent to you."
        end
        return "Oops, there seems no new image..."
      end
    end

    def get_latest_image_hash
      image_hash = Cache.get("image/last")
      return false if image_hash.nil?
      return false unless Cache.exists?("image/#{image_hash}")
      image_hash
    end

  end
end
