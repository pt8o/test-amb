require_relative "#{Rails.root}/lib/utils/openai_request"

class AskController < ApplicationController
  include OpenAiRequest

  def create
    question = params[:question]
    response = get_new_answer(question)
    render json: response, status: :created
  end

  private

  def get_new_answer(question)
    completion = get_completion(question)
    { 'message' => completion }
  end
end
