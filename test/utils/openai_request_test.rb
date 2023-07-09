require 'test_helper'
require 'webmock/minitest'

require_relative './mocks/compare_embeddings_mock'

class OpenaiRequestTest < ActiveSupport::TestCase
  include OpenaiRequest
  include CompareEmbeddingsMock

  def setup
    @completions_body = '{
      "id": "chatcmpl-123",
      "object": "chat.completion",
      "created": 1677652288,
      "choices": [{
        "index": 0,
        "message": {
          "role": "assistant",
          "content": "\n\nHello there, how may I assist you today?"
        },
        "finish_reason": "stop"
      }],
      "usage": {
        "prompt_tokens": 9,
        "completion_tokens": 12,
        "total_tokens": 21
      }
    }'

    @embeddings_body = '{
      "object": "list",
      "data": [
        {
          "object": "embedding",
          "embedding": [0.123, 0.456, 0.789],
          "index": 0
        }
      ],
      "model": "text-embedding-ada-002",
      "usage": {
        "prompt_tokens": 8,
        "total_tokens": 8
      }
    }'

    stub_request(:post, 'https://api.openai.com/v1/chat/completions')
      .to_return(status: 200, body: @completions_body, headers: {})

    stub_request(:post, 'https://api.openai.com/v1/embeddings')
      .to_return(status: 200, body: @embeddings_body, headers: {})
  end

  test 'openai_request returns response' do
    response = openai_request('completions', {
                                'input' => 'This is a test'
                              })

    assert_equal '200', response.code
    assert_equal response.body, @completions_body
  end

  test 'get_embeddings returns embedding' do
    embedding = get_embeddings('This is a test')

    assert_equal [0.123, 0.456, 0.789], embedding
  end

  test 'get_completion returns completion' do
    completion = get_completion('This is a test')

    assert_equal "\n\nHello there, how may I assist you today?", completion
  end
end
