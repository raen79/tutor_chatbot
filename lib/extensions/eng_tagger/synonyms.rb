class EngTagger::Synonyms < EngTagger
  def initialize(sentence)
    super()
    @tagged_sentence = add_tags(sentence)
  end

  def get_relevant_words
    get_nouns(@tagged_sentence).keys +
      get_proper_nouns(@tagged_sentence).keys +
      get_adjectives(@tagged_sentence).keys +
      get_cardinal_adjectives(@tagged_sentence)
  end

  private
    def get_cardinal_adjectives(tagged_question)
      Nokogiri::HTML(tagged_question).xpath('//cd').children.map{ |tag| tag.text }
    end
end
