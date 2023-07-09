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
    csv_data = CSV.read("#{Rails.root}/lib/assets/#{ENV['TEXT_CSV_FILENAME']}", headers: true)
    texts = csv_data['text']
    text_embeddings = csv_data['embedding'].map { |embedding| JSON.parse(embedding) }

    relatedness_scores = text_embeddings.map do |embedding|
      cosine_similarity(Vector[*embedding], Vector[*query_embeddings])
    end

    sorted_texts = texts.zip(relatedness_scores).sort_by { |_, score| -score }.map(&:first)

    # TODO: this is a crude way to limit the request size. Instead, count the tokens and return texts up to the limit.
    sorted_texts.first(5)
  end
end
