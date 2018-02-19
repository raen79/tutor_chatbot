require 'semantic_similarity'

FactoryBot.define do
  factory :synonym do
    word "MyString"
    words ["Word1", "Word2"]
  end
  factory :faq do
    question "MyString"
    answer "MyString"
  end
  factory :semantic_similarity, class: SemanticSimilarity do
    first_question "Do you know if this film is available in color?"
    second_question "Are you aware whether this movie exists not in black and white?"

    initialize_with { new(first_question, second_question) }
  end
end