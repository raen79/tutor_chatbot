json.extract! faq, :id, :question, :answer, :lecturer_id, :module_id, :coursework_id, :created_at, :updated_at
json.url faq_url(faq, format: :json)
