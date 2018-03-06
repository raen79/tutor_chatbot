class Faq < ApplicationRecord
  before_create :associate_synonyms
  before_validation :upcase_id

  has_and_belongs_to_many :synonyms
 
  validates :question,
            :uniqueness => { :case_insensitive => false, :scope => :coursework_id },
            :question => { :attr => :question },
            :presence => true
  validates :answer, :length => { :minimum => 3 }, :presence => true
  validates :lecturer_id, :presence => true
  validates :module_id, :presence => true
  validates :coursework_id, :presence => true

  def self.find_answer(question:, module_id:, coursework_id:, student_id:, lecturer_id:)
    return 'Your question must be greater than or equal to 3 characters.' if question.length < 3
    return 'Your question must be lower than or equal to 140 characters.' if question.length > 140
    return 'Your question must end in a question mark.' unless question.last == '?'
    
    @possible_answers = possible_answers(question, coursework_id)
    
    case @possible_answers.size
      when 0
        StudentQuestion.create!(
          :text => question,
          :module_id => module_id,
          :coursework_id => coursework_id,
          :lecturer_id => lecturer_id,
          :student_id => student_id
        )

        'I have found no answer to your question, I\'ll ask my supervisor and reply to you by email.'
      when 1
        @possible_answers.first
      else
        'I have found multiple answers to your question:<br />' +
        @possible_answers.join('<br /><br /><b>or</b><br /><br />')
    end
  end

  private
    def question_must_end_with_question_mark
      unless question.last == '?'
        errors.add(:question, 'must end with question mark')
      end
    end

    def associate_synonyms
      self.synonyms = Synonym.in_sentence(question)
    end

    def upcase_id
      [:lecturer_id, :module_id, :coursework_id].each do |attribute|
        if !self[attribute].blank? && self[attribute].kind_of?(String)
          self[attribute].upcase!
        end
      end
    end

    def self.possible_answers(question, coursework_id)
      possible_answers = []

      tagger = EngTagger::Synonyms.new(question)
      tagger.get_relevant_words.combination(2).each do |first_word, second_word|
        faqs = Faq.joins(:synonyms)
                  .where(:coursework_id => coursework_id)
                  .where("'#{first_word}' = ANY (synonyms.words) OR synonyms.word = '#{first_word}'") &
               Faq.joins(:synonyms)
                  .where(:coursework_id => coursework_id)
                  .where("'#{second_word}' = ANY (synonyms.words) OR synonyms.word = '#{second_word}'")
  
        possible_answers = possible_answers | faqs.pluck(:answer)
      end

      possible_answers
    end
end
