module API
  class WooCommerce
    class << self
      def client
        @client ||= ::WooCommerce::API.new(
          ENV["WOOCOMMERCE_URL"],
          ENV["WOOCOMMERCE_KEY"],
          ENV["WOOCOMMERCE_SECRET"],
          {
            wp_api: true,
            version: 'wc/v1'
          }
        )
      end

      def create_product(data)
        client.post("products", data)
      end

      def delete_product(id)
        client.delete("products/#{id}")
      end

      def products
        client.get("products")
      end

      def validate_domain( domain )
        client.get("domain", { domain: domain })
      end
    end
  end
end
