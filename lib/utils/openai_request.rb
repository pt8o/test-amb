require 'dotenv/load'
require 'uri'
require 'net/http'

module OpenAiRequest
  OPENAI_API = {
    'embeddings' => {
      'url' => 'https://api.openai.com/v1/embeddings',
      'model' => ENV['OPENAI_EMBEDDINGS_MODEL']
    },
    'completions' => {
      'url' => 'https://api.openai.com/v1/chat/completions',
      'model' => ENV['OPENAI_COMPLETIONS_MODEL']
    }
  }

  def openapi_request(request_type, body)
    return { 'error' => 'Invalid request type' } if OPENAI_API[request_type].empty?

    url = OPENAI_API[request_type]['url']
    model = OPENAI_API[request_type]['model']

    parsed_url = URI.parse(url)
    http = Net::HTTP.new(parsed_url.host, parsed_url.port)
    http.use_ssl = true

    request = Net::HTTP::Post.new(parsed_url.path)
    request['Content-Type'] = 'application/json'
    request['Accept'] = 'application/json'
    request['Authorization'] = "Bearer #{ENV['OPENAI_API_KEY']}"

    complete_body = body
    complete_body['model'] = model
    request.body = complete_body.to_json

    http.request(request)
  end
end
