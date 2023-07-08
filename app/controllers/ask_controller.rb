require 'uri'
require 'net/http'
require 'dotenv/load'

class AskController < ApplicationController
  OPENAI_API = {
    'embeddings' => {
      'url' => 'https://api.openai.com/v1/embeddings',
      'model' => 'text-embedding-ada-002'
    },
    'completions' => {
      'url' => 'https://api.openai.com/v1/chat/completions',
      'model' => 'gpt-3.5-turbo'
    }
  }

  def create
    question = params[:question]
    response = get_new_answer
    render json: response, status: :created
  end

  private

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

  def get_new_answer
    response = openapi_request(
      'completions',
      {
        'messages' => [{ "role": 'user', "content": 'Say this is a test!' }],
        'max_tokens' => 150,
        'temperature' => 0.0
      }
    )

    return { 'error' => response.body } unless response.is_a?(Net::HTTPSuccess)

    response_body = JSON.parse(response.body)
    { 'message' => response_body['choices'][0]['message']['content'] }
  end
end
