require 'base64'
require 'json'
require 'securerandom'

module Application
  class UploadContext < Context
    def process(event)

      if is_image?(event)
        image_url = upload_to_s3(event.id)
        Cache.set("image/last", image_url)

        LineAPI.client.send_text(event.from_mid, "Ok, I got your image!")
        LineAPI.client.send_image(event.from_mid, image_url, image_url)
      else
        LineAPI.client.send_text(event.from_mid, "Invalid type of image!")
      end

      Context.store(event.from_mid, HelpContext)
    end

    def upload_image(id)
      response = LineAPI.client.get_image(id)
      upload_to_s3(response.body, response.header['Content-Type'])
    end

    # @return [String] S3 Public URL
    def upload_to_s3(image_body, content_type)
      API::S3.bucket.put_object({
        acl: 'public-read', # Let image readable
        key: SecureRandom.hex(16), # Random Image ID
        body: image_body,
        metadata: {
          'Content-Type': content_type
        }
      }).public_url
    end
  end
end
