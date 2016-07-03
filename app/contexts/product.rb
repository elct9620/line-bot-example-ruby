module Application
  class ProductContext < Context
    FIVE_MINUTES = 5 * 60
    IMAGE_HOST = "https://image.avg.gift"

    def process(event)
      case step(event.from_mid)
      when "set_name"
        set_name(event)
      when "set_description"
        set_description(event)
      when "set_price"
        set_price(event)
      when "set_image"
        set_image(event)
      when "confirm"
        do_confirm(event)
      else
        LineAPI.client.send_text(event.from_mid, "Please tell me product name...")
        set_step(event.from_mid, "set_name")
      end
    end

    def step(mid)
      Cache.get("user/#{mid}/product/step")
    end

    def set_step(mid, step)
      Cache.set("user/#{mid}/product/step", step, ex: FIVE_MINUTES )
    end

    def set_product(mid, attribute, value)
      Cache.set("user/#{mid}/product/#{attribute}", value, ex: FIVE_MINUTES)
    end

    def get_product(mid, attribute)
      Cache.get("user/#{mid}/product/#{attribute}")
    end

    def set_text_value(event, attribute, next_step)
      unless is_text?(event)
          LineAPI.client.send_text(event.from_mid, "Please send text to me")
          return false
      end
      set_product(event.from_mid, attribute, event.content[:text])
      set_step(event.from_mid, next_step)
      true
    end

    def set_name(event)
      return unless set_text_value(event, "name", "set_description")
      LineAPI.client.send_text(event.from_mid, "Next, please send description to me")
    end

    def set_description(event)
      return unless set_text_value(event, "description", "set_price")
      LineAPI.client.send_text(event.from_mid, "Now, please tell me product price")
    end

    def set_price(event)
      return LineAPI.client.send_text(event.from_mid, "Please send text to me") unless is_text?(event)
      set_product(event.from_mid, "price", event.content[:text].to_f)
      set_step(event.from_mid, "set_image")
      LineAPI.client.send_text(event.from_mid, "The last step, please upload a image for me")
    end

    def set_image(event)
      return LineAPI.client.send_text(event.from_mid, "Please send image to me") unless is_image?(event)
      upload_image(event)
    end

    def do_confirm(event)
      response = "Ok, your new product creation is cancel"
      if is_text?(event) and event.content[:text] == "YES"
        API::WooCommerce.create_product({
          name: get_product(event.from_mid, "name"),
          description: get_product(event.from_mid, "description"),
          regular_price: get_product(event.from_mid, "price"),
          images: [
            {
              src: get_product(event.from_mid, "image"),
              position: 0
            }
          ]
        })
        response = "Ok, your new product is created"
      end

      LineAPI.client.send_text(event.from_mid, response)
      Context.store(event.from_mid, HelpContext)
    end

    def upload_image(event)
      response = LineAPI.client.get_image(event.id)
      hash = SecureRandom.hex(16)
      upload_to_s3(hash, response.body, response.header['Content-Type'])
      set_product(event.from_mid, "image", "#{IMAGE_HOST}/#{hash}")
      set_step(event.from_mid, "do_confirm")
      LineAPI.client.send_text(event.from_mid, "Finally, send YES to me to create new product")
    end

    # @return [String] S3 Public URL
    def upload_to_s3(hash, image_body, content_type)
      API::S3.bucket.put_object({
        acl: 'public-read', # Let image readable
        key: hash, # Random Image ID
        body: image_body,
        metadata: {
          'Content-Type': content_type
        }
      }).public_url
    end

  end
end
