FactoryBot.define do
  factory :synonym do
    word "MyString"
    words ["Word1", "Word2"]
  end

  factory :faq do
    question "Do you know if this film is available in color?"
    answer "Answer"
  end
end