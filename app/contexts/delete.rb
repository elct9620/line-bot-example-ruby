module Application
  class DeleteContext < Context
    def process(event)
      response = "Please give me a valid id"
      if is_text?(event)
        API::WooCommerce.delete_product(event.content[:text].to_i)
        response = "Ok, the product is removed"
      end

      LineAPI.client.send_text(event.from_mid, response)
      Context.store(event.from_mid, HelpContext.name)
    end
  end
end
