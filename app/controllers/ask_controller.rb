class AskController < ApplicationController
  def create
    question = params[:question]
    render plain: question, status: :created
  end
end
