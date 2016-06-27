class Cache
  # Singleton
  class << self

    def connect(options = {})
      options[:url] ||= ENV['REDIS_URL']
      @redis ||= Redis.new(options)
    end

    def set(key, value, options)
      connect.set(key, value, options)
    end

    def get(key)
      connect.get(key)
    end

  end
end
