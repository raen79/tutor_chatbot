class Faq < ApplicationRecord
  before_save :associate_synonyms

  has_and_belongs_to_many :synonyms

  validates :question, :length => { :minimum => 3, :maximum => 140 }
  validates :answer, :length => { :minimum => 3 }
  validate :question_must_end_with_question_mark

  def self.find_answer(question)
    return 'Your question must be greater than or equal to 3 characters.' if question.length < 3
    return 'Your question must be lower than or equal to 140 characters.' if question.length > 140
    return 'Your question must end in a question mark.' unless question.last == '?'

    tagger = EngTagger::Synonyms.new(question)
    possible_answers = []

    tagger.get_relevant_words.combination(2).each do |first_word, second_word|
      faqs = Faq.joins(:synonyms)
                .where("'#{first_word}' = ANY (synonyms.words) OR synonyms.word = '#{first_word}'") &
             Faq.joins(:synonyms)
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
end
