class StudentQuestion < ApplicationRecord
  before_validation :upcase_id
  before_create :contact_lecturer

  validates :text, :question => true
  validates :lecturer_id, :presence => true
  validates :student_id, :presence => true
  validates :module_id, :presence => true
  validates :coursework_id, :presence => true

  def answer(answer)
    raise ArgumentError, 'answer should be >= 3' if answer.length < 3

    ActiveRecord::Base.transaction do
      @faq = Faq.create!(
        :question => self.text,
        :answer => answer,
        :module_id => self.module_id,
        :lecturer_id => self.lecturer_id,
        :coursework_id => self.coursework_id
      )
      self.destroy!
    end

    @faq
  end

  private
    def upcase_id
      [:lecturer_id, :module_id, :coursework_id, :student_id].each do |attribute|
        if !self[attribute].blank? && self[attribute].kind_of?(String)
          self[attribute].upcase!
        end
      end
    end

    def contact_lecturer
      QuestionMailer.ask_lecturer(self).deliver_now
    end
end
