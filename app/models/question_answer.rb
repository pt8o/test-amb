class QuestionAnswer < ApplicationRecord
  # Validations, if any
  validates :question, :answer, presence: true
end
