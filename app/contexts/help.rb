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
      when "Product"
        Context.store(event.from_mid, ProductContext.name)
        return "Send 'New' to start create product"
      when "Delete"
        Context.store(event.from_mid, DeleteContext.name)
        return show_product_list
      when "Help", "?"
        return %{
          The robot can process below command ---
          Upload: upload a image
          Echo: return same message from you
          Image: get latest upload image
        }
      when "Image"
        # TODO: Split below code into it's own context
        image_url = get_latest_image_url
        if image_url
          LineAPI.client.send_image(event.from_mid, image_url, image_url)
          return "Ok, the latest image I alreay sent to you."
        end
        return "Oops, there seems no new image..."
      end
    end

    def get_latest_image_url
      image_url = Cache.get("image/last")
      return false if image_url.nil?
      image_url
    end

    def show_product_list
      products = API::WooCommerce.products.parsed_response
      response = "Tell me ID which product you want delete"
      products.each do |product|
        response << "\n" << "#{product['id']} - #{product['name']}"
      end
      response
    end

  end
end
