class AskController < ApplicationController
  include OpenaiRequest

  def create
    question = params[:question]
    question_answer = QuestionAnswer.find_by(question:)

    if question_answer
      response = {
        'message' => question_answer.answer
      }
    else
      response = get_new_answer(question)
      question_answer = QuestionAnswer.new(question:, answer: response['message'])
      question_answer.save
    end

    render json: response, status: :created
  end

  private

  def get_new_answer(question)
    completion = get_completion(question)
    { 'message' => completion }
  end
end
