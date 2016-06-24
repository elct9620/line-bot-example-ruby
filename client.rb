
require 'base64'
require 'net/http'

class Client

  attr_accessor :channel_id, :channel_secret, :channel_mid

  def initialize(options = {})
    options.each do |key, value|
      instance_variable_set("@#{key}", value)
    end
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
