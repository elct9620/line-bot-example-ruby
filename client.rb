
require 'json'
require 'base64'
require 'net/http'

class BotHTTPClient
  def http(uri)
    http = Net::HTTP.new(uri.host, uri.port)
    if uri.scheme == "https"
      http.use_ssl = true
    end

    http
  end

  def post(url, payload, header = {})
    uri = URI(url)
    http(uri).post(uri.request_uri, payload, header)
  end
end

class Client

  attr_accessor :channel_id, :channel_secret, :channel_mid

  def initialize(options = {})
    options.each do |key, value|
      instance_variable_set("@#{key}", value)
    end

    @httpclient ||= BotHTTPClient.new
  end

  def credentials
    {
      'X-Line-ChannelID' => channel_id,
      'X-Line-ChannelSecret' => channel_secret,
      'X-Line-Trusted-User-With-ACL' => channel_mid
    }
  end

  def credentials?
    credentials.values.all?
  end

  def validate_signature(content = "", channel_signature)
    return false unless !channel_signature.nil? && credentials?

    hash = OpenSSL::HMAC::digest(OpenSSL::Digest::SHA256.new, channel_secret, content)
    signature = Base64.strict_encode64(hash)

    variable_secure_compare(channel_signature, signature)
  end

  def send_text(to_mid, message)
    request = Request.new do |config|
      config.to = to_mid
      config.to_channel_id = 1383378250
      config.endpoint = 'https://trialbot-api.line.me/v1'
      config.endpoint_path = '/events'
      config.credentials = credentials
      config.content = content
      config.messageType = 1
      config.httpclient = httpclient
    end

    request.post
  end

  private

  def variable_secure_compare(a, b)
    secure_compare(::Digest::SHA256.hexdigest(a), ::Digest::SHA256.hexdigest(b))
  end

  def secure_compare(a, b)
    return false if a.bytesize != b.bytesize

    l = a.unpack "C#{a.bytesize}"

    res = 0
    b.each_byte { |byte| res |= byte ^ l.shift }
    res == 0
  end

end

class Request

  attr_accessor :to, :to_channel_id, :messageType, :content, :credentials, :httpclient, :endpoint, :endpoint_path

  def initialize
    yield(self) if block_given?
  end

  def payload
    payload = {
      to: to,
      toChannel: to_channel_id,
      eventType: messageType,
      content: content

    }

    payload.to_json
  end

  def header
    header = {
      'Content-Type' => 'application/json; charset=UTF-8',
      'User-Agent' => 'MOHO-Bot/1.0.0'
    }
    hash = credentials.inject({}) { |h, (k, v)| h[k] = v.to_s; h }

    header.merge(hash)
  end

  def post
    httpclient.post(endpoint + endpoint_path, payload, header)
  end
end
