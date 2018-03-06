Rails.application.routes.draw do
  scope 'coursework/:coursework_id' do
    resources :faqs
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
