require 'csv'
require 'rails_helper'

require_relative '../../lib/utils/compare_embeddings'

class TestClass
end

# Assuming you're using RSpec
RSpec.describe 'CompareEmbeddings' do
  describe '#compare_embeddings' do
    before(:each) do
      @test_class = TestClass.new
      @test_class.extend(CompareEmbeddings)
    end

    it 'returns the sorted texts based on the provided embeddings' do
      # Mock the CSV data
      csv_data = <<~CSV
        text,embedding,tokens
        Text 1,"[0.9, 0.8, 0.7]",10
        Text 2,"[0.3, 0.2, 0.1]",10
        Text 3,"[0.6, 0.5, 0.4]",10
      CSV

      # Parse the mock CSV data
      mock_csv = CSV.parse(csv_data, headers: true, liberal_parsing: true)

      # Stub CSV.read to return the mock CSV data
      allow(CSV).to receive(:read).and_return(mock_csv)

      # Call the method and test the result
      query_embeddings = [0.1, 0.2, 0.3]
      result = @test_class.compare_embeddings(query_embeddings)

      expect(result).to eq(['Text 1', 'Text 3', 'Text 2'])
    end

    it 'does not exceed MAX_OUTPUT_TOKENS' do
      # Mock the CSV data
      csv_data = <<~CSV
        text,embedding,tokens
        Text 1,"[0.9, 0.8, 0.7]",10
        Text 2,"[0.3, 0.2, 0.1]",#{MAX_INPUT_TOKENS}
        Text 3,"[0.6, 0.5, 0.4]",10
      CSV

      # Parse the mock CSV data
      mock_csv = CSV.parse(csv_data, headers: true, liberal_parsing: true)

      # Stub CSV.read to return the mock CSV data
      allow(CSV).to receive(:read).and_return(mock_csv)

      # Call the method and test the result
      query_embeddings = [0.1, 0.2, 0.3]
      result = @test_class.compare_embeddings(query_embeddings)

      expect(result).to eq(['Text 1', 'Text 3'])
    end
  end
end
