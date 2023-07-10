require 'matrix'
require 'csv'
require 'dotenv/load'

module CompareEmbeddings
  def cosine_similarity(vector1, vector2)
    dot_product = vector1.inner_product(vector2)
    magnitude1 = Math.sqrt(vector1.inner_product(vector1))
    magnitude2 = Math.sqrt(vector2.inner_product(vector2))
    dot_product / (magnitude1 * magnitude2)
  end

  def compare_embeddings(query_embeddings)
    csv_data = CSV.read("#{Rails.root}/lib/assets/#{ENV['PDF_FILENAME']}.embeddings.csv", headers: true)

    texts = csv_data['text']
    text_embeddings = csv_data['embedding'].map { |embedding| JSON.parse(embedding) }
    tokens = csv_data['tokens'].map { |token| JSON.parse(token) }

    relatedness_scores = text_embeddings.map do |embedding|
      cosine_similarity(Vector[*embedding], Vector[*query_embeddings])
    end

    sorted_texts_with_tokens = texts.zip(tokens).zip(relatedness_scores).sort_by { |(_, score)| -score }
    sorted_texts = sorted_texts_with_tokens.map { |(text_and_tokens, _)| text_and_tokens[0] }
    sorted_tokens = sorted_texts_with_tokens.map { |(text_and_tokens, _)| text_and_tokens[1] }

    result_texts = []
    cumulative_tokens = 0

    sorted_texts.each_with_index do |text, index|
      cumulative_tokens += sorted_tokens[index]
      break if cumulative_tokens > MAX_INPUT_TOKENS

      result_texts << text
    end

    result_texts
  end
end
