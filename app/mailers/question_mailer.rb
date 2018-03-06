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

  def receive_answer(mail)
    student_question = find_student_question_by_subject(mail.subject)
    student = User.find_by(:student_id => student_question.student_id)
    @faq = student_question.answer(mail.decoded)

    mail(
      :from => ENV['GM_USER'],
      :to => student.email,
      :reply_to => mail.from,
      :subject => "SQ##{student_question.id} | Your tutor has replied to your question"
    )
  end

  def self.receive_answers
    Mail.all.map { |mail| QuestionMailer.receive_answer(mail) }
  end

  private
    def find_student_question_by_subject(subject)
      student_question_id = subject[/SQ#(.*?) \| /, 1].to_i
      StudentQuestion.find(student_question_id)
    end
end
