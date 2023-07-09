require 'dotenv/load'
require 'uri'
require 'net/http'

module OpenaiRequest
  include CompareEmbeddings

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
    request['Authorization'] = "Bearer #{ENV['OPENAI_API_KEY']}"

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
        'content' => "You are an assistant answering questions about a book.\n
          Please keep answers to three sentences maximum.\n
          Answer questions solely based on the text provided, not based on your own outside knowledge.\n
          If you don't know the answer to something, please say: 'Sorry, I don't know the answer to that based on this book's contents.'\n
          If you don't understand a question, please say: 'Sorry, I don't understand the question.'\n
          \n
          The book is 'Stories of My Dogs' by Leo Tolstoy.\n
          Here are some of the most pertinent passages:\n
          #{sorted_texts.join("\n")}
        "
      },
      {
        'role' => 'user',
        'content' => question
      }
    ]

    response = openai_request('completions', {
                                'max_tokens' => 150,
                                'temperature' => 0.0,
                                'messages' => messages
                              })

    completion_content = JSON.parse(response.body)

    puts completion_content
    completion_content['choices'][0]['message']['content']
  end
end
