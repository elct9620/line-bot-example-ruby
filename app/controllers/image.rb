require 'base64'
require 'json'

class ImageController < Application::Base

  get '/' do
    error 404, "No Image Found"
  end

  get '/:id' do
    data = Cache.get("image/#{params['id']}")
    error 404, "Image Not Found" if data.nil?
    data = JSON.parse(data)

    content_type data['type']
    Base64.strict_decode64(data['body'])
  end
end
