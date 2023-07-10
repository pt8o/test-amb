class AskController < ApplicationController
  include OpenaiRequest

  def create
    question = params[:question][0, 120]
    question_answer = QuestionAnswer.find_by(question:)

    if question_answer
      response = {
        'message' => question_answer.answer
      }
    else
      response = get_completion(question)

      unless response.key?('error')
        question_answer = QuestionAnswer.new(question:, answer: response['message'])
        question_answer.save
      end
    end

    render json: response, status: :created
  end
end
