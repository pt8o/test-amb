RSpec.describe AskController, type: :controller do
  describe 'POST #create' do
    let(:question) { 'This is a test' }

    before do
      allow(controller).to receive(:get_new_answer).and_return('Confirmed, this is a test')
    end

    it 'returns a successful response' do
      post :create, params: { question: }
      expect(response).to have_http_status(:created)
    end

    it 'returns the expected response body' do
      post :create, params: { question: }
      expect(JSON.parse(response.body)).to eq({ 'message' => 'Confirmed, this is a test' })
    end

    it 'calls get_new_answer with the provided question' do
      expect(controller).to receive(:get_new_answer).with(question)
      post :create, params: { question: }
    end
  end
end
