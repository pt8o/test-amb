require 'uri'
require 'net/http'

module OpenaiRequest
  include CompareEmbeddings

  OPENAI_API = {
    'embeddings' => {
      'url' => OPENAI_EMBEDDINGS_ENDPOINT,
      'model' => OPENAI_EMBEDDINGS_MODEL
    },
    'completions' => {
      'url' => OPENAI_COMPLETIONS_ENDPOINT,
      'model' => OPENAI_COMPLETIONS_MODEL
    }
  }

  def openai_request(request_type, body)
    return { 'error' => 'Invalid request type' } if OPENAI_API[request_type].empty?

    url = OPENAI_API[request_type]['url']
    model = OPENAI_API[request_type]['model']

    parsed_url = URI.parse(url)
    http = Net::HTTP.new(parsed_url.host, parsed_url.port)
    http.use_ssl = true

    request = Net::HTTP::Post.new(parsed_url.path)
    request['Content-Type'] = 'application/json'
    request['Accept'] = 'application/json'
    request['Authorization'] = "Bearer #{OPENAI_API_KEY}"

    complete_body = body
    complete_body['model'] = model
    request.body = complete_body.to_json

    http.request(request)
  end

  def get_embeddings(text)
    response = openai_request('embeddings', {
                                'input' => text
                              })

    response_parsed = JSON.parse(response.body)
    response_parsed['data'][0]['embedding']
  end

  def get_completion(question)
    sorted_texts = compare_embeddings(get_embeddings(question))

    messages = [
      {
        'role' => 'system',
        'content' => "You're an assistant answering questions about a book.\n
          Keep answers to three sentences maximum.\n
          Answer based on the text provided, not your own outside knowledge.\n
          If you don't know the answer, say: 'Sorry, I don't know the answer to that based on the book's contents.'\n
          If you don't understand a question, say: 'Sorry, I don't understand the question.'\n
          \n
          The book is 'Stories of My Dogs' by Leo Tolstoy, nonfiction, written from Tolstoy's perspective.\n
          Here are the most relevant passages for this question:\n
          #{sorted_texts.join("\n")}
        "
      },
      {
        'role' => 'user',
        'content' => question
      }
    ]

    response = openai_request('completions', {
                                'max_tokens' => MAX_OUTPUT_TOKENS,
                                'temperature' => 0.0,
                                'messages' => messages
                              })

    return { 'error' => 'Sorry, there was an error!' } unless response.code == '200'

    completion_content = JSON.parse(response.body)
    { 'message' => completion_content['choices'][0]['message']['content'] }
  end
end
