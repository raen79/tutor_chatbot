class Faq < ApplicationRecord
  before_save :associate_synonyms
  before_validation :upcase_id

  has_and_belongs_to_many :synonyms

  validates :question, :length => { :minimum => 3, :maximum => 140 }, :uniqueness => { :case_insensitive => false, :scope => :module_id }
  validates :answer, :length => { :minimum => 3 }
  validates :lecturer_id, :presence => true
  validates :module_id, :presence => true
  validate :question_must_end_with_question_mark

  def self.find_answer(question, module_id)
    return 'Your question must be greater than or equal to 3 characters.' if question.length < 3
    return 'Your question must be lower than or equal to 140 characters.' if question.length > 140
    return 'Your question must end in a question mark.' unless question.last == '?'

    tagger = EngTagger::Synonyms.new(question)
    possible_answers = []

    tagger.get_relevant_words.combination(2).each do |first_word, second_word|
      faqs = Faq.joins(:synonyms)
                .where(:module_id => module_id)
                .where("'#{first_word}' = ANY (synonyms.words) OR synonyms.word = '#{first_word}'") &
             Faq.joins(:synonyms)
                .where(:module_id => module_id)
                .where("'#{second_word}' = ANY (synonyms.words) OR synonyms.word = '#{second_word}'")

      possible_answers = possible_answers | faqs.pluck(:answer)
    end
    
    possible_answers
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
      if !lecturer_id.blank? && lecturer_id.kind_of?(String)
        lecturer_id.upcase!
      end

      if !module_id.blank? && module_id.kind_of?(String)
        module_id.upcase!
      end
    end
end
