class AskController < ApplicationController
  include OpenaiRequest

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
