class Synonym < ApplicationRecord
  before_validation :downcase_word

  has_and_belongs_to_many :faqs

  validates :word, :uniqueness => { :case_sensitive => false }, :presence => true
  validate :words_validations

  def self.in_sentence(sentence)
    raise ArgumentError, 'sentence must be >= 3 chars' if sentence.length < 3

    tagger = EngTagger::Synonyms.new(sentence)

    tagger.get_relevant_words.uniq.map do |word|
      word = word.singularize

      existing_synonyms = Synonym.where(:word => word)

      if existing_synonyms.blank?
        synonyms = Datamuse.words(ml: word).map { |synonym| synonym['word'] }
        Synonym.new(:word => word, :words => synonyms)
      else
        existing_synonyms.first
      end
    end
  end

  private
    def words_validations
      if words.kind_of?(Array)
        words.each do |word|
          if is_numeric?(word)
            errors.add(:words, 'must only include strings')
            break
          end
        end
      else
        errors.add(:words, 'must be array')
      end
    end

    def downcase_word
      if !word.blank? && word.kind_of?(String)
        word.downcase!
      end
    end

    def is_numeric?(value)
      true if Float(value) rescue false
    end
end
