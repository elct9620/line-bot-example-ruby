module Application
  class Context
    class << self
      def restore(user_id)
        user_context = Cache.get("user/#{user_id}")
        user_context ||= 'Application::HelpContext'
        puts "User Context: #{user_context}"
        get(user_context)
      end

      def get(context)
        context = HelpContext.name unless exists?(context)
        context = context.name if context.is_a?(Class)
        @context ||= {}
        @context[context.to_sym] ||= Object.const_get(context).new
      end

      def store(user_id, context)
        puts "User next context #{context}"
        puts "User next context #{get(context).class.name}"
        Cache.set("user/#{user_id}", get(context).class.name, ex: 5 * 60)
      end

      def exists?(context)
        return context.is_a?(Context) unless context.is_a?(String)
        p "Is String"
        return false unless Object.const_defined?(context)
        p "Is defined"
        p Object.const_get(context)
        p Object.const_get(context).is_a?(Context)
        Object.const_get(context).is_a?(Context)
      end
    end

    def process(event)
      raise NotImplementedError, "Should implement this method in child class"
    end

    def is_text?(event)
      event.content.is_a?(Line::Bot::Message::Text)
    end

    def is_image?(event)
      event.content.is_a?(Line::Bot::Message::Image)
    end
  end
end
