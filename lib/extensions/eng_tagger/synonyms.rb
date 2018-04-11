require 'lemmatizer'

class EngTagger::Synonyms < EngTagger
  def initialize(sentence)
    super()
    @tagged_sentence = add_tags(sentence.downcase)
    @lem = Lemmatizer.new
  end

  def get_relevant_words
    get_nouns(@tagged_sentence) +
      get_proper_nouns(@tagged_sentence) +
      get_adjectives(@tagged_sentence) +
      get_cardinal_adjectives(@tagged_sentence)
  end

  def get_nouns(sentence)
    words = super(sentence).keys
    words.map do |key|
      @lem.lemma(key)
    end
  end

  def get_proper_nouns(sentence)
    super(sentence).keys
  end

  def get_adjectives(sentence)
    words = super(sentence).keys
    words.map do |key|
      @lem.lemma(key)
    end
  end


  private
    def get_cardinal_adjectives(tagged_question)
      Nokogiri::HTML(tagged_question).xpath('//cd').children.map { tag.text }
    end
end
