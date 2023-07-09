class CreateQuestionAnswers < ActiveRecord::Migration[7.0]
  def change
    create_table :question_answers do |t|
      t.string :question
      t.string :answer

      t.timestamps
    end
  end
end
