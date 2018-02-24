require 'rubymuse'

class SemanticSimilarity
  attr_accessor :first_question, :second_question

  def initialize(first_question, second_question)
    self.first_question = first_question
    self.second_question = second_question
  end

  def first_question=(first_question)
    raise ArgumentError, 'first_question must be greater than or equal to 3 characters.' unless first_question.length >= 3
    raise ArgumentError, 'first_question must be lower than or equal to 140 characters.' unless first_question.length <= 140
    raise ArgumentError, 'first_question must end in a question mark.' unless first_question[-1] == "?"

    @first_question = first_question
    @first_question_plain_array = first_question.downcase.gsub(/[^a-z0-9\s]/i, '').split(' ')
  end

  def second_question=(second_question)
    raise ArgumentError, 'second_question must be greater than or equal to 3 characters.' unless second_question.length >= 3
    raise ArgumentError, 'second_question must be lower than or equal to 140 characters.' unless second_question.length <= 140
    raise ArgumentError, 'second_question must end in a question mark.' unless second_question[-1] == "?"

    @second_question = second_question
    @second_question_plain_array = second_question.downcase.gsub(/[^a-z0-9\s]/i, '').split(' ')
  end

  def score
    0
    # count = 0

    # @first_question_plain_array.each do |first_question_word|
    #   synonyms = Datamuse.words(ml: first_question_word, max: 100)
    #   @second_question_plain_array.each do |second_question_word|
    #     if first_question_word == second_question_word
    #       count += 1
    #       break
    #     end  
        
    #     words_match = synonyms.select { |synonym| synonym['word'] == second_question_word }.first

    #     if words_match != nil && words_match["score"] >= 20000
    #       count += 1
    #       break
    #     end
    #   end
    # end
    
    # count.to_f / @first_question_plain_array.size.to_f
  end
end