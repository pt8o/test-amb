require_relative "#{Rails.root}/lib/utils/openai_request"

class AskController < ApplicationController
  include OpenAiRequest

  def create
    question = params[:question]
    response = get_new_answer
    render json: response, status: :created
  end

  private

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
