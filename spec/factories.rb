FactoryBot.define do
  factory :synonym do
    word "MyString"
    words ["Word1", "Word2"]
  end

  factory :faq do
    question "Do you know if this film is available in color?"
    answer "Answer"
    lecturer_id "C1529373"
    module_id "CM3245"
  end
end