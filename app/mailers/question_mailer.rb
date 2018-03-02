class QuestionMailer < ApplicationMailer
  def ask_lecturer(student_question)
    @student_question = student_question
    lecturer = User.find_by(:lecturer_id => student_question.lecturer_id)

    mail(
      :from => ENV['GM_USER'],
      :to => lecturer.email,
      :subject => "SQ##{student_question.id} | Tutor Chatbot Has a New Question for You"
    )
  end

  def self.receive_answers
    Mail.all.each do |mail|
      student_question_id = mail.subject[/SQ#(.*?) \| /, 1].to_i
      student_question = StudentQuestion.find(student_question_id)
      student_question.answer(mail.decoded)
    end
  end
end
