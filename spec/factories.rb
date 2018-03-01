FactoryBot.define do
  factory :student_question do
    text "Do you know if this film is available in color?"
    coursework_id "4312"
    lecturer_id "C1529373"
    module_id "CM32546"
    student_id "C1529372"
  end
  factory :synonym do
    word "MyString"
    words ["Word1", "Word2"]
  end

  factory :faq do
    question "Do you know if this film is available in color?"
    answer "Answer"
    lecturer_id "C1529373"
    module_id "CM3245"
    coursework_id "4312"
  end
end