module Application
  class HelpContext < Context

    def process(event)
      response = process_text(event, event.content[:text]) if is_text?(event)
      response ||= "Send Help or ? to show help message\n輸入 幫助 或者 ? 顯示幫助訊息"
      LineAPI.client.send_text(event.from_mid, response)
    end

    def process_text(event, text)
      case text
      when "Upload", "上傳"
        Context.store(event.from_mid, UploadContext.name)
        return "Please upload a image for me\n請上傳一張圖片給我"
      when "Echo", "回聲"
        Context.store(event.from_mid, EchoContext.name)
        return "Please send any thing for me\n請輸入任意訊息給我"
      when "Product", "上架"
        Context.store(event.from_mid, ProductContext.name)
        return "Send 'New' to start create product\n輸入 'New' 開始上架"
      when "Delete", "刪除"
        Context.store(event.from_mid, DeleteContext.name)
        return show_product_list
      when "Help", "?", "幫助"
        return %{
          機器人目前支援以下指令：
          上傳：上傳一張圖片
          回聲：傳回相同的訊息（測試用）
          圖片：顯示最近上傳的圖片
          上架：上架商品到 bot.vcart.mobi
          刪除：刪除某個上架的商品
        }
      when "Image", "圖片"
        # TODO: Split below code into it's own context
        image_url = get_latest_image_url
        if image_url
          LineAPI.client.send_image(event.from_mid, image_url, image_url)
          return "Ok, the latest image I alreay sent to you.\n我已經把最新的圖片傳給你了！"
        end
        return "Oops, there seems no new image...\n喔喔，目前沒有找到其他圖片喔！"
      end
    end

    def get_latest_image_url
      image_url = Cache.get("image/last")
      return false if image_url.nil?
      image_url
    end

    def show_product_list
      products = API::WooCommerce.products.parsed_response
      response = "Tell me ID which product you want delete\n告訴我哪個商品 ID 想要刪除"
      products.each do |product|
        response << "\n" << "#{product['id']} - #{product['name']}"
      end
      response
    end

  end
end
