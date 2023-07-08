require 'uri'
require 'net/http'
require 'dotenv/load'

OPENAI_COMPLETIONS_MODEL = 'gpt-3.5-turbo'.freeze

class AskController < ApplicationController
  def create
    question = params[:question]
    response = get_new_answer
    render json: response, status: :created
  end

  def get_new_answer
    parsed_url = URI.parse('https://api.openai.com/v1/chat/completions')
    http = Net::HTTP.new(parsed_url.host, parsed_url.port)
    http.use_ssl = true

    request = Net::HTTP::Post.new(parsed_url.path)
    request['Content-Type'] = 'application/json'
    request['Accept'] = 'application/json'
    request['Authorization'] = "Bearer #{ENV['OPENAI_API_KEY']}"
    request.body = {
      'model' => OPENAI_COMPLETIONS_MODEL,
      'messages' => [{ "role": 'user', "content": 'Say this is a test!' }],
      'max_tokens' => 150,
      'temperature' => 0.0
    }.to_json

    response = http.request(request)

    return { 'error' => response.body } unless response.is_a?(Net::HTTPSuccess)

    response_body = JSON.parse(response.body)
    { 'message' => response_body['choices'][0]['message']['content'] }
  end
end
