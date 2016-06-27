require 'base64'
require 'json'
require 'securerandom'

module Application
  class UploadContext < Context
    def process(event)

      if is_image?(event)
        image_hash = SecureRandom.hex(16)
        Cache.set("image/#{image_hash}", get_image_information(event.id).to_json)
        Cache.set("image/last", image_hash)

        image_url = "#{ENV['APP_HOST']}/image/#{image_hash}"

        LineAPI.client.send_text(event.from_mid, "Ok, I got your image!")
        LineAPI.client.send_image(event.from_mid, image_url, image_url)
      else
        LineAPI.client.send_text(event.from_mid, "Invalid type of image!")
      end

      Content.store(event.from_mid, HelpContext.name)
    end

    def get_image_information(id)
      response = LineAPI.client.get_image(id)

      {
        type: response['Content-Type'],
        body: Base64.strict_encode64(response.body)
      }
    end
  end
end
