module Application
  class CreateSiteContext < Context
    FIVE_MINUTES = 5 * 60

    def process(event)
      case step(event.from_mid)
      when "domain"
        set_domain(event)
      when "name"
        set_name(event)
      else
        LineAPI.client.send_text(event.from_mid, "發生錯誤！")
        Context.store(event.from_mid, HelpContext.name)
      end
    end

    def step(mid)
      Cache.get("user/#{mid}/create_site/step")
    end

    def set_step(mid, step)
      Cache.set("user/#{mid}/create_site/step", step, ex: FIVE_MINUTES )
    end

    def set_config(mid, attribute, value)
      Cache.set("user/#{mid}/create_site/#{attribute}", value, ex: FIVE_MINUTES)
    end

    def get_config(mid, attribute)
      Cache.get("user/#{mid}/create_site/#{attribute}")
    end

    def set_text_value(event, attribute, next_step)
      unless is_text?(event)
          LineAPI.client.send_text(event.from_mid, "Please send text to me\n請發送文字訊息給我")
          return false
      end
      set_config(event.from_mid, attribute, event.content[:text])
      set_step(event.from_mid, next_step)
      true
    end

    def set_domain(event)
      unless is_text?(event)
          LineAPI.client.send_text(event.from_mid, "請發送文字訊息給我")
          return false
      end

      result = API::WooCommerce.validate_domain(event.content[:text])
      if result["status"].nil?
        LineAPI.client.send_text(event.from_mid, "錯誤：#{result["message"]}")
        return false
      end

      Context.store(event.from_mid, HelpContext.name)
    end

    def set_name(event)
      return unless set_text_value(event, "name", "set_description")
      LineAPI.client.send_text(event.from_mid, "Next, please send description to me\n請告訴我商品的說明")
    end

  end
end
