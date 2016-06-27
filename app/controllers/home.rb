require 'json'

class HomeController < Application::Base
  get '/' do
    content_type 'application/json'

    {
      agent: "Aotokitsuruya Line Bot",
      version: Application::VERSION
    }.to_json
  end
end
